import 'package:get/get.dart';

class SubscriptionController extends GetxController {
  RxBool produtsLoading = true.obs;

  String? orderId = "";
  String planID = '', type = '';
  double amount = 0;
  var selectedPlanIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }










}
