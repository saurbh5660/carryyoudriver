import 'dart:io';
import 'dart:ui' as ui;
import 'package:carry_you_driver/model/booking_detail_response.dart';
import 'package:carry_you_driver/network/api_provider.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:carry_you_driver/network/api_constants.dart';
import 'package:geolocator_platform_interface/src/models/position.dart';
import '../common/apputills.dart';
import '../common/location_service.dart';
import '../common/socket_service.dart';
import '../generated/assets.dart';
import '../model/lost_item_request_detail_response.dart';
import '../routes/app_routes.dart';

class LostItemMapController extends GetxController implements SocketListener, LocationListener {
  final SocketService socketService = SocketService();
  Rx<LostItemRequestDetail> requestBody = Rx(LostItemRequestDetail());
  late GoogleMapController mapController;
  late LocationService locationService;

  RxDouble latitude = 30.7126.obs;
  RxDouble longitude = 76.6914.obs;
  RxSet<Polyline> polylines = <Polyline>{}.obs;

  RxString distance = '0 miles'.obs;
  RxString duration = '0 mins'.obs;
  BitmapDescriptor? driverIcon;
  RxDouble heading = 0.0.obs;

  LatLng get dropOffLatLng {
    double lat = double.tryParse(requestBody.value.dropLatitude ?? "0.0") ?? 0.0;
    double lng = double.tryParse(requestBody.value.dropLongitude ?? "0.0") ?? 0.0;
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
    getRequestDetail();
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
  Future<void> getRequestDetail() async {
    final Map<String, dynamic> map = {
      "lostItemId": Get.arguments?["requestId"] ?? ""
    };
    var response = await ApiProvider().lostItemRequestDetail(map, true);
    if (response.success == true) {
      requestBody.value = response.body ?? LostItemRequestDetail();
      fetchRoute();
    }
  }

  Future<void> fetchRoute() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: ApiConstants.placesKey,
      request: PolylineRequest(
        origin: PointLatLng(latitude.value, longitude.value),
        destination: PointLatLng(dropOffLatLng.latitude, dropOffLatLng.longitude),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      List<LatLng> coords = result.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
      polylines.value = {
        Polyline(
          polylineId: const PolylineId("lost_item_route"),
          color: Colors.black,
          points: coords,
          width: 5,
        ),
      };
      _updateCamera(coords);
    }
  }

  void _updateCamera(List<LatLng> points) {
    if (points.isEmpty) return;
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b),
        points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b),
      ),
      northeast: LatLng(
        points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b),
        points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b),
      ),
    );
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
  }

  Future<void> updateStatus(String status) async {
    final Map<String, dynamic> map = {
      "bookingId": Get.arguments?["bookingId"] ?? "",
      "startNavigationStatus": status,
    };
    var response = await ApiProvider().startNavigation(map, true);
    if (response.success == true) {
      requestBody.value = response.body ?? LostItemRequestDetail();
      if (status == "3") {
        Get.back();
        Utils.showSuccessToast(message: "Item returned successfully!");
      } else if (status == "2") {
        Utils.showSuccessToast(message: "Arrival notified to user");
      }
    }
  }

  @override
  void onSocketEvent(data, String eventType) {
    if (eventType == 'startNavigation') {
      try {
        print("ROUTE STATUSS: $data");
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
    // updateAddressFromLocation(position.latitude, position.longitude);
    // }
  }
  void updateMapRoute() {
    // LatLng driverPos = LatLng(latitude.value, longitude.value);
    polylines.clear();
    fetchRoute();
  }

  @override
  void onClose() {
    socketService.removeListener(this);
    locationService.stopLocationUpdates();
    super.onClose();
  }

}