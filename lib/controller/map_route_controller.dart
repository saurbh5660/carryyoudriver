import 'dart:io';
import 'dart:ui' as ui;

import 'package:carry_you_driver/generated/assets.dart';
import 'package:carry_you_driver/model/booking_detail_response.dart';
import 'package:carry_you_driver/network/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator_platform_interface/src/models/position.dart';
import 'package:get/get.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart' as nav;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import '../common/apputills.dart';
import '../common/db_helper.dart';
import '../common/location_service.dart';
import '../common/socket_service.dart';
import '../network/api_provider.dart';
import 'package:geolocator/geolocator.dart';

import '../routes/app_routes.dart';

class MapRouteController extends GetxController
    implements SocketListener, LocationListener {
  final SocketService socketService = SocketService();
  Rx<BookingDetailBody> requestBody = Rx(BookingDetailBody());
  late LocationService locationService;
  RxDouble latitude = 0.0.obs;
  RxDouble longitude = 0.0.obs;
  RxString location = ''.obs;
  RxDouble heading = 0.0.obs;
  RxDouble userLatitude = 0.0.obs;
  RxDouble userLongitude = 0.0.obs;
  RxSet<Polyline> polylines = <Polyline>{}.obs;

  /// Raw polyline points fetched from Google Directions API.
  RxList<LatLng> routePoints = <LatLng>[].obs;

  Rx<BitmapDescriptor> carIcon = BitmapDescriptor.defaultMarker.obs;
  RxString distance = '0 m'.obs;
  RxString duration = '0 mins'.obs;
  GoogleMapController? mapController;
  BitmapDescriptor? driverIcon;
  
  RxInt iconVersion = 0.obs;

  bool _isNearbyNotificationSent = false;

  LatLng get pickupLatLng {
    double lat =
        double.tryParse(requestBody.value.pickUpLatitude ?? "0.0") ?? 0.0;
    double lng =
        double.tryParse(requestBody.value.pickUpLongitude ?? "0.0") ?? 0.0;
    return LatLng(lat, lng);
  }

  LatLng get dropOffLatLng {
    double lat =
        double.tryParse(requestBody.value.destinationLatitude ?? "0.0") ?? 0.0;
    double lng =
        double.tryParse(requestBody.value.destinationLongitude ?? "0.0") ?? 0.0;
    return LatLng(lat, lng);
  }

  @override
  void onInit() {
    super.onInit();
    Logger().i("MapRouteController.onInit");
    socketService.addListener(this);
    locationService = LocationService(this);
    startLocation();
    loadCustomIcons();
    getBookingDetail();
  }

  Future<void> loadCustomIcons() async {
    if (driverIcon != null) {
      Logger().i("loadCustomIcons: already loaded, skipping");
      return;
    }
    try {
      Logger().i("loadCustomIcons: decoding ${Assets.icons.car.path}");
      final bmp = await getBytesFromAsset(Assets.icons.car.path, 100);
      driverIcon = bmp;
      iconVersion.value++;
      update();
      Logger().i("loadCustomIcons: SUCCESS, driverIcon ready");
    } catch (e, st) {
      // Asset missing / unable to decode. Fall back to the default
      // marker so SOMETHING shows on screen, and surface the real
      // error in the log so we can fix the asset.
      driverIcon = BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueBlue,
      );
      iconVersion.value++;
      update();
      Logger().e(
        "loadCustomIcons: FAILED to decode ${Assets.icons.car.path} - using default marker as fallback",
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<BitmapDescriptor> getBytesFromAsset(String path, int width) async {
    final targetWidth = Platform.isIOS ? width * 1.5 : width * 1.5;

    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: targetWidth.toInt(),
      targetHeight: targetWidth.toInt(),
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    final bytes = (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(bytes);
  }

  void startLocation() {
    locationService.startLocationUpdates();
  }

  Future<void> getBookingDetail() async {
    final Map<String, dynamic> map = {
      "bookingId" : Get.arguments?["bookingId"] ?? ""
    };
    var response = await ApiProvider().bookingDetail(map, true);
    if (response.success == true) {
      _isNearbyNotificationSent = false;
      requestBody.value = response.body ?? BookingDetailBody();
      
      // Initialize user location from booking detail
      final userLat = double.tryParse(requestBody.value.user?.latitude ?? "0.0") ?? 0.0;
      final userLng = double.tryParse(requestBody.value.user?.longitude ?? "0.0") ?? 0.0;
      if (userLat != 0.0) {
        userLatitude.value = userLat;
        userLongitude.value = userLng;
      }

      ensureRouteFetched();
    } else {
      Utils.showErrorToast(message: response.message ?? "");
    }
  }

  /// Phase of the booking that determines which destination the
  /// driver is heading towards (and therefore which route to draw):
  ///
  /// * `none`    → status 1 (accepted, not started). NO route drawn yet.
  /// * `pickup`  → status 4 (slide to start pressed) or 5 (arrival confirmed). Driver → pickup.
  /// * `dropoff` → status 10+ (picked up). Driver → drop-off.
  String routePhase(int? status) {
    if (status == 4 || status == 1 || status == 5) return 'pickup';
    if (status != null && status >= 10 && status != 7) return 'dropoff';
    return 'none';
  }

  /// Active destination, derived from `routePhase`. Returns null when no
  /// route should be drawn (e.g. status 1 - waiting for driver to start).
  LatLng? get activeDestination {
    final phase = routePhase(requestBody.value.status?.toInt());
    LatLng? dest;
    if (phase == 'pickup') dest = pickupLatLng;
    if (phase == 'dropoff') dest = dropOffLatLng;
    if (dest == null) return null;
    if (dest.latitude == 0.0 && dest.longitude == 0.0) return null;
    return dest;
  }

  /// Fetches the directions polyline only if we don't already have a
  /// route for the current destination. Safe to call repeatedly.
  void ensureRouteFetched({bool force = false}) {
    // google_navigation_flutter handles routing internally.
  }

  /// Redraws the route from the driver's CURRENT location to the active
  /// destination.
  void reroute() {
    // google_navigation_flutter handles rerouting internally.
  }

  /// Updates distance / duration labels from Navigation progress.
  void updateNavProgress(
    double? distanceMeters,
    double? durationSeconds,
  ) {
    if (distanceMeters != null) {
      final miles = distanceMeters * 0.000621371;
      if (miles < 0.1) {
        distance.value = "${(miles * 5280).toStringAsFixed(0)} ft";
      } else {
        distance.value = "${miles.toStringAsFixed(1)} miles";
      }
    }
    if (durationSeconds != null) {
      if (durationSeconds < 60) {
        duration.value = "1 min";
      } else if (durationSeconds < 3600) {
        duration.value = "${(durationSeconds / 60).ceil()} mins";
      } else {
        final hours = durationSeconds ~/ 3600;
        final mins = (durationSeconds % 3600) ~/ 60;
        duration.value = "$hours hr $mins mins";
      }
    }
    // Hit this api when user is nearby of the pickup location (less than 5 minutes)
    // Hit only once when driver is en route to pickup (status 1: Accepted or 4: En Route).
    _checkNearbyTrigger(durationSeconds);
  }

  void _checkNearbyTrigger(double? durationSeconds) {
    final currentStatus = requestBody.value.status?.toInt();
    Logger().d("Nearby Check: durationSeconds=$durationSeconds, status=$currentStatus, alreadySent=$_isNearbyNotificationSent");

    if (durationSeconds != null &&
        durationSeconds > 0 &&
        durationSeconds <= 300 &&
        !_isNearbyNotificationSent &&
        (currentStatus == 1 || currentStatus == 4)) {
      Logger().i("Triggering nearby notification: Driver is $durationSeconds seconds away from pickup");
      _isNearbyNotificationSent = true;
      _sendNearbyNotification();
    }
  }

  Future<void> _sendNearbyNotification() async {
    final Map<String, dynamic> map = {
      "bookingId": requestBody.value.id.toString(),
      "restTime": duration.value,
    };
    Logger().i("Calling sendNotificationToUserWhenDriverIsNearBy API with params: $map");
    var response =
        await ApiProvider().sendNotificationToUserWhenDriverIsNearBy(map);
    if (response.success == true) {
      Logger().i("Nearby notification sent successfully");
    } else {
      // If it failed, maybe we should allow retrying?
      // The requirement says "hit this api once dont hit after that".
      // Usually that implies once it's triggered, don't trigger it again.
      Logger().e("Failed to send nearby notification: ${response.message}");
    }
  }

  Future<void> fetchRoute(LatLng origin, LatLng destination) async {
    // google_navigation_flutter handles routing internally.
  }

  void updateCameraBoundsFromPolyline(List<LatLng> points) {
    // google_navigation_flutter handles camera internally.
  }

  @override
  void onSocketEvent(data, String eventType) {
    if (eventType == 'update_route_listener') {
      try {
        final routeDetail = data['route_detail'];
        final status = routeDetail['status'];
        print("ROUTE STATUS: $status");
        if (status == 1) {
        } else {}
      } catch (e) {
        print("Error parsing update_route_listener socket data: $e");
      }
    } else if (eventType == 'user_location_update') {
      try {
        // payload: {"latitude": "...", "longitude": "...", "userId": "..."}
        final userId = data['userId']?.toString();
        if (userId == requestBody.value.userId?.toString()) {
          final lat = double.tryParse(data['latitude']?.toString() ?? "0.0") ?? 0.0;
          final lng = double.tryParse(data['longitude']?.toString() ?? "0.0") ?? 0.0;
          if (lat != 0.0) {
            userLatitude.value = lat;
            userLongitude.value = lng;
            Logger().d("User location updated via socket: $lat, $lng");
          }
        }
      } catch (e) {
        print("Error parsing loction_update socket data: $e");
      }
    }
  }

  @override
  void onLocationDisabled() {
    Logger().w("onLocationDisabled: permission denied or service off");
  }

  @override
  void onLocationUpdated(Position position) {
    Logger().i(
      "onLocationUpdated: lat=${position.latitude}, lng=${position.longitude}",
    );
    final bool firstFix = latitude.value == 0.0;

    latitude.value = position.latitude;
    longitude.value = position.longitude;
    if (position.heading.isFinite) {
      heading.value = position.heading;
    }

    // Fetch the route exactly once we have a real GPS fix and a booking,
    // and never again from inside location updates. Subsequent re-fetches
    // are only triggered by destination changes (see `updateStatus`).
    if (firstFix) {
      if (activeDestination != null) {
        ensureRouteFetched();
      } else {
        // No route to draw yet (status 1). At least frame the camera
        // around the driver and the upcoming pickup pin so the driver
        // can see where they're going.
        _frameDriverAndPickup();
      }
    }

    updateAddressFromLocation(position.latitude, position.longitude);
  }

  /// Camera fit: driver + pickup pin (used when there's no route yet).
  void _frameDriverAndPickup() {
    final pickup = pickupLatLng;
    if (latitude.value == 0.0 ||
        (pickup.latitude == 0.0 && pickup.longitude == 0.0)) {
      return;
    }
    final driverPos = LatLng(latitude.value, longitude.value);
    updateCameraBoundsFromPolyline([driverPos, pickup]);
  }

  Future<void> updateAddressFromLocation(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;

        /*String fullAddress =
            "${p.name}, ${p.street}, ${p.locality}, ${p.subLocality}, "
            "${p.administrativeArea}, ${p.postalCode}, ${p.country}";*/
        String fullAddress =
            "${p.name}, ${p.locality}, ${p.subLocality}, "
            "${p.administrativeArea}, ${p.postalCode}, ${p.country}";

        location.value = fullAddress;
        print("📌 Address: $fullAddress");
        updateLocation();
      }
    } catch (e) {
      print("❌ Reverse Geocoding Error: $e");
    }
  }

  void updateLocation() {
    var messageData = {
      "driverId": DbHelper().getUserModel()?.id.toString(),
      "latitude": latitude.value.toString(),
      "longitude": longitude.value.toString(),
      "location": location.value.toString(),
    };
    Logger().d(messageData);
    socketService.driverLocationUpdate(messageData);
  }

  Future<String?> callCustomer() async {
    final bookingId = requestBody.value.id;
    if (bookingId == null || bookingId.isEmpty) {
      Utils.showErrorToast(message: "Booking ID is missing");
      return null;
    }

    final Map<String, dynamic> body = {
      "bookingId": bookingId,
    };

    var response = await ApiProvider().callCustomer(body);
    if (response.success == true && response.body != null) {
      String? tempPhone;
      if (response.body is String) {
        tempPhone = response.body;
      } else if (response.body is Map) {
        tempPhone = response.body['phone']?.toString() ??
            response.body['phoneNumber']?.toString() ??
            response.body['temp_phone']?.toString();
      }
      return tempPhone;
    } else {
      Utils.showErrorToast(
          message: response.message ?? "Failed to get temporary number");
      return null;
    }
  }

  Future<void> updateStatus(String status) async {
    final Map<String, dynamic> map = {
      "bookingId" : Get.arguments?["bookingId"] ?? "",
      "status": status,
    };
    var response = await ApiProvider().bookingStatusChange(map, true);
    if (response.success == true) {
      requestBody.value = response.body ?? BookingDetailBody();

      if (status == "5") { // I am here
        Utils.showSuccessToast(message: "User notified. Please wait.");
      } else if (status == "10") { // Pickup Confirmed
        Utils.showSuccessToast(message: "Pickup confirmed. Heading to destination.");
      } else if (status == "6") { // Ride Completed
        Get.offNamed(AppRoutes.paymentStatus,arguments: {"bookingId" : Get.arguments?["bookingId"] ?? ""});
        Utils.showSuccessToast(message: "Trip finished. Great job!");
      } else if (status == "7") { // Ride Cancelled
        Get.back();
        Utils.showSuccessToast(message: "Ride cancelled successfully");
      }
    } else {
      Utils.showErrorToast(message: response.message ?? "");
    }
  }

  @override
  void onClose() {
    socketService.removeListener(this);
    super.onClose();
    locationService.stopLocationUpdates();
  }
}
