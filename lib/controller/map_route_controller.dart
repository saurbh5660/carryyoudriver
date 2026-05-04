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
  RxSet<Polyline> polylines = <Polyline>{}.obs;
  Rx<BitmapDescriptor> carIcon = BitmapDescriptor.defaultMarker.obs;
  RxString distance = '0 m'.obs;
  RxString duration = '0 mins'.obs;
  late GoogleMapController mapController;
  BitmapDescriptor? driverIcon;


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
    socketService.addListener(this);
    locationService = LocationService(this);
    // requestBody.value = Get.arguments?["item"] ?? RequestBody();
    startLocation();
    loadCustomIcons();
    getBookingDetail();
  }

  Future<void> loadCustomIcons() async {
    driverIcon = await getBytesFromAsset(Assets.iconsCar, 100);
    update();
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
      requestBody.value = response.body ?? BookingDetailBody();

      if (latitude.value != 0.0) {
        LatLng driverPos = LatLng(latitude.value, longitude.value);
        if (requestBody.value.status == 1) {
          fetchRoute(driverPos, pickupLatLng);
        } else {
          fetchRoute(driverPos, dropOffLatLng);
        }
      }
    } else {
      Utils.showErrorToast(message: response.message ?? "");
    }
  }

  void updateMapRoute() {
    LatLng driverPos = LatLng(latitude.value, longitude.value);
    polylines.clear();
    if (requestBody.value.status == 1) {
      fetchRoute(driverPos, pickupLatLng);
    } else {
      fetchRoute(driverPos, dropOffLatLng);
    }
  }

  Future<void> fetchRoute(LatLng origin, LatLng destination) async {
    print(
      "DEBUG: Fetching route from $origin to $destination",
    ); // CHECK THIS IN CONSOLE
    PolylinePoints polylinePoints = PolylinePoints();

    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: ApiConstants.placesKey,
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        int totalMeters = 0;
        int totalSeconds = 0;

        if (result.distanceValues != null) {
          for (int m in result.distanceValues!) {
            totalMeters += m;
          }
        }
        if (result.durationValues != null) {
          for (int s in result.durationValues!) {
            totalSeconds += s;
          }
        }

        // 2. Convert Meters to Miles (1 meter = 0.000621371 miles)
        double miles = totalMeters * 0.000621371;

        // Format: If less than 0.1 miles, show in feet, otherwise show miles
        if (miles < 0.1) {
          distance.value = "${(miles * 5280).toStringAsFixed(0)} ft";
        } else {
          distance.value = "${miles.toStringAsFixed(1)} miles";
        }

        // 3. Format Duration
        if (totalSeconds < 60) {
          duration.value = "1 min";
        } else if (totalSeconds < 3600) {
          duration.value = "${(totalSeconds / 60).ceil()} mins";
        } else {
          int hours = totalSeconds ~/ 3600;
          int mins = (totalSeconds % 3600) ~/ 60;
          duration.value = "$hours hr $mins mins";
        }
        List<LatLng> polylineCoordinates = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        polylines.value = {
          Polyline(
            polylineId: const PolylineId("route"),
            color: Colors.black,
            points: polylineCoordinates,
            width: 5,
          ),
        };

        updateCameraBoundsFromPolyline(polylineCoordinates);
      } else {
        print("DEBUG: No points found. Error: ${result.errorMessage}");
      }
    } catch (e) {
      print("DEBUG: Route error: $e");
    }
  }

  void updateCameraBoundsFromPolyline(List<LatLng> points) {
    if (points.isEmpty) return;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (LatLng point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 150), // padding
    );
  }

  @override
  void onSocketEvent(data, String eventType) {
    if (eventType == 'update_route_listener') {
      try {
        final routeDetail = data['route_detail'];
        final status = routeDetail['status'];

        print("ROUTE STATUS: $status");

        final message = data['message'];
        final stopNo = routeDetail['stop_no'];
        final machineEmpty = routeDetail['machine_empty'];
        if (status == 1) {
        } else {}
      } catch (e) {
        print("Error parsing update_route_listener socket data: $e");
      }
    }
  }

  @override
  void onLocationDisabled() {}

  @override
  void onLocationUpdated(Position position) {
    /* double distance = Geolocator.distanceBetween(
        latitude.value, longitude.value,
        position.latitude, position.longitude
    );*/

    latitude.value = position.latitude;
    // latitude.value = 30.7126;
    longitude.value = position.longitude;
    // longitude.value = 76.6914;

    // if (distance > 50) {
    heading.value = position.heading;
    updateMapRoute();
    updateAddressFromLocation(position.latitude, position.longitude);
    // }
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

  Future<void> updateStatus(String status) async {
    final Map<String, dynamic> map = {
      "bookingId" : Get.arguments?["bookingId"] ?? "",
      "status": status,
      // "bookingId": "9983b03d-b5a7-41ab-a0fc-14b9172690a8",
    };
    var response = await ApiProvider().bookingStatusChange(map, true);
    if (response.success == true) {
      requestBody.value = response.body ?? BookingDetailBody();
      if (status == "5") { // I am here
        Utils.showSuccessToast(message: "User notified. Please wait.");
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
