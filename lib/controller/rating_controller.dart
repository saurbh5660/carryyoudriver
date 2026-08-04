import 'package:get/get.dart';
import '../common/apputills.dart';
import '../model/booking_detail_response.dart';
import '../network/api_provider.dart';
import '../routes/app_routes.dart';

class RatingController extends GetxController {
  Rx<BookingDetailBody> requestBody = Rx(BookingDetailBody());
  var isLoading = false.obs;
  final selectedStars = 4.0.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments["detail"] != null) {
      requestBody.value = Get.arguments["detail"];
    }
  }

  Future<void> submitRating({
    required double rating,
    required String comment,
  }) async {
    if (comment.isEmpty) {
      Utils.showErrorToast(message: "Please add comment.");
      return;
    }
    try {
      isLoading.value = true;
      Map<String, dynamic> body = {
        "userId": requestBody.value.user?.id,
        "rating": rating,
        "comment": comment,
      };
      var response = await ApiProvider().addRating(body, true);
      if (response.success == true) {
        Get.offAllNamed(AppRoutes.homeScreen);
      } else {
        isLoading.value = false;
        Utils.showErrorToast(message: response.message);
      }
    } catch (e) {
      isLoading.value = false;
      Utils.showErrorToast(message: "Failed to add rating.");
    }
  }
}
