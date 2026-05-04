import 'package:carry_you_driver/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../model/lost_item_request_response.dart'; // Adjust path
import '../../network/api_provider.dart'; // Adjust path

class DriverLostItemController extends GetxController {
  var lostItems = <Body>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getLostItemRequests();
  }

  Future<void> getLostItemRequests() async {
    isLoading.value = true;
    try {
      LostItemRequestResponse response = await ApiProvider().lostItemRequest(true);
      if (response.success == true && response.body != null) {
        lostItems.assignAll(response.body!);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateItemStatus(String requestId, bool found) async {
    // Get.snackbar("Status Updated", found ? "Item confirmed. Waiting for rider payment." : "Request declined.");
    var status = 0;
    if(found){
      status = 1;
    }else{
      status = 2;
    }
    Map<String, dynamic> map = {
      "lostItemId": requestId,
      "status": status.toString()
    };
    final response = await ApiProvider().confirmByDriver(map,true);
    if (response.success == true) {
      getLostItemRequests();
    }
  }

  void startNavigation(Body item) async {

  }
}