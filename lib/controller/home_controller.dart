import 'dart:convert';
import 'package:carry_you_driver/network/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:carry_you_driver/model/request_list_response.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../common/apputills.dart';
import '../common/db_helper.dart';
import '../common/location_service.dart';
import '../common/socket_service.dart';
import '../network/api_provider.dart';
import '../routes/app_routes.dart';

class HomeController extends GetxController implements LocationListener, SocketListener {
  RxList<RequestBody> requestList = RxList();
  late LocationService locationService;
  final socketService = SocketService();

  // Observable for online status
  RxBool isOnline = false.obs;

  RxDouble latitude = 0.0.obs;
  RxDouble longitude = 0.0.obs;
  RxString location = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize status from local DB user model
    isOnline.value = DbHelper().getUserModel()?.isOnline == 1;

    socketService.connectToServer();
    socketService.setListener(this);
    locationService = LocationService(this);
    locationService.startLocationUpdates();
  }

  // Fetch requests only if the driver is online
  Future<void> getRequests(bool loader) async {
    if (!isOnline.value) return;

    var response = await ApiProvider().requestList(loader);
    if (response.success == true) {
      requestList.clear();
      requestList.assignAll(response.body ?? []);
      fetchAllRoadDistances();
    } else {
      Utils.showErrorToast(message: response.message ?? "Failed to fetch requests");
    }
  }

  // API Call to toggle status
  Future<void> isOnlineStatusChange() async {
    // If currently true, we send 0 (offline), if false, send 1 (online)
    int nextStatus = isOnline.value ? 0 : 1;
    Map<String, dynamic> data = {"isOnline": nextStatus};

    var response = await ApiProvider().isOnlineStatusChange(data, true);
    if (response.success == true) {
      isOnline.value = (nextStatus == 1);
      var model =  DbHelper().getUserModel();
      model?.isOnline = isOnline.value == true ? 1 : 0;
      DbHelper().saveUserModel(model);
      if (isOnline.value) {
        getRequests(true); // Load data immediately when going online
      } else {
        requestList.clear(); // Clear list for privacy/UI when offline
      }
    } else {
      Utils.showErrorToast(message: response.message ?? "Status change failed");
    }
  }

  void fetchAllRoadDistances() async {
    for (var item in requestList) {
      if (item.pickUpLatitude != null && latitude.value != 0.0) {
        double pLat = double.tryParse(item.pickUpLatitude!) ?? 0.0;
        double pLng = double.tryParse(item.pickUpLongitude!) ?? 0.0;
        item.distanceTxt = await getActualRoadDistance(pLat, pLng);
      }
    }
    requestList.refresh();
  }

  Future<String> getActualRoadDistance(double destLat, double destLng) async {
    final url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${latitude.value},${longitude.value}&destination=$destLat,$destLng&mode=driving&key=${ApiConstants.placesKey}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return data['routes'][0]['legs'][0]['distance']['text'];
        }
      }
    } catch (e) {
      Logger().e("Distance API Error: $e");
    }
    return "N/A";
  }

  @override
  void onLocationUpdated(Position position) {
    locationService.stopLocationUpdates();
    latitude.value = position.latitude;
    longitude.value = position.longitude;
    updateAddressFromLocation(position.latitude, position.longitude);
  }

  Future<void> updateAddressFromLocation(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        location.value = placemarks.first.locality ?? "";
        updateLocation();
      }
    } catch (e) {
      Logger().e("Geocoding error: $e");
    }
  }

  Future<void> updateLocation() async {
    Map<String, dynamic> data = {
      "location": location.value,
      "latitude": latitude.value.toString(),
      "longitude": longitude.value.toString(),
    };
    await ApiProvider().updateLocation(data, false);
  }

  Future<void> acceptReject(String status, String bookingId, RequestBody item) async {
    Map<String, dynamic> data = {"status": status, "bookingId": bookingId};
    var response = await ApiProvider().bookingAcceptReject(data, true);
    if (response.success == true) {
      requestList.removeWhere((element) => element.id.toString() == bookingId);
      requestList.refresh();
      if (status == "1") {
        Get.toNamed(AppRoutes.mapScreen, arguments: {"bookingId": bookingId, "item": item});
      } else {
        // requestList.removeWhere((element) => element.id.toString() == bookingId);
      }
    }
  }

  @override
  void onSocketEvent(data, String eventType) {
    if (eventType == 'createBooking' && isOnline.value) {
      getRequests(false);
    }
  }

  @override
  void onLocationDisabled() => Utils.showErrorToast(message: "Enable Location Services");

}