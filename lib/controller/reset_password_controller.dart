import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../common/apputills.dart';
import '../network/api_provider.dart';

class ResetPasswordController extends GetxController {
  TextEditingController emailController = TextEditingController();

  Future<void> forgotPasswordApi() async {
    if (emailController.text.trim().isEmpty) {
      Utils.showErrorToast(message: "Please enter email.");
      return;
    }
    if (!emailController.text.trim().isEmail) {
      Utils.showErrorToast(message: "Please enter valid email.");
      return;
    }

    Map<String, dynamic> body = {
      "email": emailController.text.trim(),
    };

    var response = await ApiProvider().forgotPassword(body);
    Logger().d(response);
    if (response.success == true) {
      Get.back();
      Utils.showSuccessToast(message: response.message ?? "OTP sent successfully.");

    } else {
      Utils.showErrorToast(message: response.message ?? "Something went wrong.");
    }
  }
}
