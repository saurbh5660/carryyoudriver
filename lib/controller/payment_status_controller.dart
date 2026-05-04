import 'package:get/get.dart';
import '../common/apputills.dart';
import '../model/booking_detail_response.dart';
import '../network/api_provider.dart';

class PaymentStatusController extends GetxController {
  Rx<BookingDetailBody> requestBody = Rx(BookingDetailBody());

  Future<void> getBookingDetail() async {
    final Map<String, dynamic> map = {
      "bookingId" : Get.arguments?["bookingId"] ?? ""
      // "bookingId": "9983b03d-b5a7-41ab-a0fc-14b9172690a8",
    };
    var response = await ApiProvider().bookingDetail(map, true);
    if (response.success == true) {
      requestBody.value = response.body ?? BookingDetailBody();
    } else {
      Utils.showErrorToast(message: response.message ?? "");
    }
  }
}
