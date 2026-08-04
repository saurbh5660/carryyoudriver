import 'dart:convert';
import 'package:carry_you_driver/network/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:carry_you_driver/model/request_list_response.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../common/apputills.dart';
import '../common/db_helper.dart';
import '../common/location_service.dart';
import '../common/socket_service.dart';
import '../network/api_provider.dart';
import '../routes/app_routes.dart';

class HomeController extends GetxController
    implements LocationListener, SocketListener {

  static const bool _handleCreateBookingSocket = true;
  static const bool _enableSocketConnection = true;
  static const bool _enableLocationTracking = true;
  static const bool _enableLocationApiUpdate = true;
  static const bool _enableRequestListMutation = true;

  /// REQUEST LIST
  RxList<RequestBody> requestList = <RequestBody>[].obs;

  /// SERVICES
  late LocationService locationService;
  final socketService = SocketService();

  /// ONLINE STATUS
  RxBool isOnline = false.obs;

  /// LOCATION DATA
  RxDouble latitude = 0.0.obs;
  RxDouble longitude = 0.0.obs;
  RxString location = ''.obs;

  /// GOOGLE MAP CONTROLLER
  GoogleMapController? mapController;

  /// MARKERS
  RxSet<Marker> markers = <Marker>{}.obs;

  @override
  void onInit() {
    super.onInit();

    /// GET ONLINE STATUS FROM LOCAL USER
    isOnline.value = DbHelper().getUserModel()?.isOnline == 1;

    /// SOCKET
    if (_enableSocketConnection) {
      socketService.connectToServer();
      socketService.addListener(this);
    } else {
      Logger().d("SOCKET_TRACE socket connection disabled for crash isolation");
    }

    /// LOCATION
    locationService = LocationService(this);
    if (_enableLocationTracking) {
      locationService.startLocationUpdates().catchError((Object e, StackTrace stackTrace) {
        Logger().e(
          "Location updates failed to start",
          error: e,
          stackTrace: stackTrace,
        );
      });
    } else {
      Logger().d("LOCATION_TRACE location tracking disabled for crash isolation");
    }
  }

  /// ============================
  /// GET REQUEST LIST
  /// ============================
  Future<void> getRequests(bool loader) async {
    if (!isOnline.value) return;

    try {
      Logger().d("REQUEST_TRACE getRequests start loader=$loader");
      var response = await ApiProvider().requestList(loader);
      Logger().d(
        "REQUEST_TRACE getRequests response success=${response.success} count=${response.body?.length ?? 0}",
      );

      if (response.success == true) {
        if (!_enableRequestListMutation) {
          Logger().d("REQUEST_TRACE requestList mutation disabled for crash isolation");
          return;
        }

        Logger().d("REQUEST_TRACE clearing requestList");
        requestList.clear();
        Logger().d("REQUEST_TRACE assigning requestList");
        requestList.assignAll(response.body ?? []);
        Logger().d("REQUEST_TRACE requestList assigned count=${requestList.length}");

        Logger().d("REQUEST_TRACE fetchAllRoadDistances start");
        await fetchAllRoadDistances();
        Logger().d("REQUEST_TRACE fetchAllRoadDistances complete");
      } else {
        Utils.showErrorToast(
          message: response.message ?? "Failed to fetch requests",
        );
      }
    } catch (e, stackTrace) {
      Logger().e("Get requests failed", error: e, stackTrace: stackTrace);
    }
  }

  /// ============================
  /// ONLINE / OFFLINE
  /// ============================
  Future<void> isOnlineStatusChange() async {

    int nextStatus = isOnline.value ? 0 : 1;

    Map<String, dynamic> data = {
      "isOnline": nextStatus
    };

    try {
      var response =
      await ApiProvider().isOnlineStatusChange(data, true);

      if (response.success == true) {

        isOnline.value = nextStatus == 1;

        var model = DbHelper().getUserModel();
        model?.isOnline = isOnline.value ? 1 : 0;

        DbHelper().saveUserModel(model);

        if (isOnline.value) {
          getRequests(true);
        } else {
          requestList.clear();
        }

      } else {
        Utils.showErrorToast(
          message: response.message ?? "Status change failed",
        );
      }
    } catch (e, stackTrace) {
      Logger().e("Online status change failed", error: e, stackTrace: stackTrace);
    }
  }

  /// ============================
  /// LOCATION UPDATE
  /// ============================
  @override
  void onLocationUpdated(Position position) {
    try {

      latitude.value = position.latitude;
      longitude.value = position.longitude;

      Logger().d("Driver Lat: ${latitude.value}");
      Logger().d("Driver Lng: ${longitude.value}");

      /// MOVE MAP CAMERA
      mapController
          ?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(latitude.value, longitude.value),
        ),
      )
          .catchError((Object e, StackTrace stackTrace) {
        Logger().e(
          "Home map camera update failed",
          error: e,
          stackTrace: stackTrace,
        );
      });

      /// UPDATE DRIVER MARKER
      markers.clear();

      markers.add(
        Marker(
          markerId: const MarkerId("driver"),
          position: LatLng(latitude.value, longitude.value),
        ),
      );

      /// GET ADDRESS
      updateAddressFromLocation(
        position.latitude,
        position.longitude,
      ).catchError((Object e, StackTrace stackTrace) {
        Logger().e(
          "Location address update failed",
          error: e,
          stackTrace: stackTrace,
        );
      });
    } catch (e, stackTrace) {
      Logger().e(
        "Location update handling failed",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  void onLocationDisabled() {
    // Utils.showErrorToast(message: "Enable Location Services");
  }

  /// ============================
  /// REVERSE GEOCODING
  /// ============================
  Future<void> updateAddressFromLocation(
      double lat, double lng) async {

    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        location.value = placemarks.first.locality ?? "";

        if (_enableLocationApiUpdate) {
          await updateLocation();
        } else {
          Logger().d("LOCATION_TRACE updateLocation disabled for crash isolation");
        }
      }

    } catch (e, stackTrace) {
      Logger().e("Geocoding error", error: e, stackTrace: stackTrace);
    }
  }

  /// ============================
  /// UPDATE LOCATION API
  /// ============================
  Future<void> updateLocation() async {

    Map<String, dynamic> data = {
      "location": location.value,
      "latitude": latitude.value.toString(),
      "longitude": longitude.value.toString(),
    };

    try {
      await ApiProvider().updateLocation(data, false);
    } catch (e, stackTrace) {
      Logger().e("Update location API failed", error: e, stackTrace: stackTrace);
    }
  }

  /// ============================
  /// ACCEPT / DECLINE BOOKING
  /// ============================
  Future<void> acceptReject(
      String status,
      String bookingId,
      RequestBody item) async {

    try {
      Map<String, dynamic> data = {
        "status": status,
        "bookingId": bookingId
      };

      var response =
      await ApiProvider().bookingAcceptReject(data, true);

      if (response.success == true) {

        requestList.removeWhere(
                (element) => element.id.toString() == bookingId);

        requestList.refresh();

        if (status == "1") {
          Get.toNamed(
            AppRoutes.mapScreen,
            arguments: {
              "bookingId": bookingId,
              "item": item
            },
          );
        }
      } else {
        Utils.showErrorToast(message: response.message ?? "Request update failed");
      }
    } catch (e, stackTrace) {
      Logger().e("Accept/reject failed", error: e, stackTrace: stackTrace);
      Utils.showErrorToast(message: "Request update failed");
    }
  }

  /// ============================
  /// SOCKET LISTENER
  /// ============================
  @override
  void onSocketEvent(data, String eventType) {

    if (eventType == 'createBooking' && isOnline.value) {
      if (!_handleCreateBookingSocket) {
        Logger().d("SOCKET_TRACE createBooking ignored for crash isolation");
        return;
      }
      getRequests(false);
    }
  }

  /// ============================
  /// DISTANCE CALCULATION
  /// ============================
  Future<void> fetchAllRoadDistances() async {

    try {
      final currentRequests = List<RequestBody>.from(requestList);

      for (final item in currentRequests) {
        try {
          Logger().d("DISTANCE_TRACE start booking=${item.id}");

          if (item.pickUpLatitude != null &&
              latitude.value != 0.0) {

            double pLat =
                double.tryParse(item.pickUpLatitude!) ?? 0.0;

            double pLng =
                double.tryParse(item.pickUpLongitude ?? "") ?? 0.0;

            final distanceText = await getActualRoadDistance(pLat, pLng);
            final currentItem = requestList.firstWhereOrNull(
              (request) => request.id == item.id,
            );
            currentItem?.distanceTxt = distanceText;
            Logger().d("DISTANCE_TRACE complete booking=${item.id} distance=$distanceText");
          } else {
            Logger().d("DISTANCE_TRACE skipped booking=${item.id}");
          }
        } catch (e, stackTrace) {
          Logger().e(
            "Distance calculation failed for booking=${item.id}",
            error: e,
            stackTrace: stackTrace,
          );
        }
      }

      requestList.refresh();
    } catch (e, stackTrace) {
      Logger().e("Road distance calculation failed", error: e, stackTrace: stackTrace);
    }
  }

  Future<String> getActualRoadDistance(
      double destLat,
      double destLng) async {

    final url =
        "https://maps.googleapis.com/maps/api/directions/json"
        "?origin=${latitude.value},${longitude.value}"
        "&destination=$destLat,$destLng"
        "&mode=driving"
        "&key=${ApiConstants.placesKey}";

    try {

      Logger().d("DISTANCE_TRACE calling directions API");
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 8),
      );
      Logger().d("DISTANCE_TRACE directions status=${response.statusCode}");

      if (response.statusCode == 200) {

        final data = json.decode(response.body);
        Logger().d("DISTANCE_TRACE directions apiStatus=${data['status']}");

        if (data['status'] == 'OK') {
          return data['routes'][0]['legs'][0]['distance']['text'];
        }
      }

    } catch (e, stackTrace) {
      Logger().e("Distance API Error", error: e, stackTrace: stackTrace);
    }

    return "N/A";
  }

  /// ============================
  /// DISPOSE
  /// ============================
  @override
  void onClose() {
    locationService.stopLocationUpdates();
    socketService.removeListener(this);

    super.onClose();
  }
}