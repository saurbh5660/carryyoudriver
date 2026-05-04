import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../common/apputills.dart';
import '../common/camera_helper.dart';
import '../network/api_provider.dart';
import '../routes/app_routes.dart';

class LicenseDetailController extends GetxController implements CameraOnCompleteListener {
  final licenseFront = RxnString();
  final licenseBack = RxnString();
  final formKey = GlobalKey<FormState>();

  late CameraHelper cameraHelper;

  // Controllers
  final licenseNoController = TextEditingController();
  final issuedOnController = TextEditingController();
  final licenseTypeController = TextEditingController();
  final dobController = TextEditingController();
  final nationalityController = TextEditingController();
  final expiryController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    cameraHelper = CameraHelper(this);
  }

  @override
  void onSuccessFile(String file, String fileType, int code) {
    if (file.isNotEmpty) {
      if (code == 1) licenseFront.value = file;
      if (code == 2) licenseBack.value = file;
    }
  }

  @override
  void onSuccessVideo(String selectedUrl, Uint8List? thumbnail) {}

  Future<void> submitLicenseData() async {
    if (licenseFront.value == null) {
      Utils.showErrorToast(message: "Please upload License Front side photo.");
      return;
    }
    if (licenseBack.value == null) {
      Utils.showErrorToast(message: "Please upload License Back side photo.");
      return;
    }
    if (licenseNoController.text.trim().isEmpty) {
      Utils.showErrorToast(message: "Please enter License Number.");
      return;
    }

    if (!formKey.currentState!.validate()) {
      return;
    }

    if (issuedOnController.text.isEmpty) {
      Utils.showErrorToast(message: "Please select License Issue Date.");
      return;
    }
    if (licenseTypeController.text.isEmpty) {
      Utils.showErrorToast(message: "Please select a License Type.");
      return;
    }
    if (dobController.text.isEmpty) {
      Utils.showErrorToast(message: "Please select Date of Birth.");
      return;
    }
    if (nationalityController.text.trim().isEmpty) {
      Utils.showErrorToast(message: "Please enter Nationality.");
      return;
    }
    if (expiryController.text.isEmpty) {
      Utils.showErrorToast(message: "Please select License Expiry Date.");
      return;
    }

    try {
      DateFormat format = DateFormat('yyyy-MM-dd');
      DateTime issuedDate = format.parse(issuedOnController.text);
      DateTime expiryDate = format.parse(expiryController.text);
      DateTime dob = format.parse(dobController.text);
      DateTime today = DateTime.now();

      // Age Validation
      int age = today.year - dob.year;
      if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) age--;
      if (age < 18) {
        Utils.showErrorToast(message: "Driver must be at least 18 years old.");
        return;
      }

      // Logical Sequence Validation
      if (expiryDate.isBefore(today)) {
        Utils.showErrorToast(message: "License has expired. Cannot proceed.");
        return;
      }
      if (expiryDate.isBefore(issuedDate)) {
        Utils.showErrorToast(message: "Expiry date cannot be before the issue date.");
        return;
      }
    } catch (e) {
      Utils.showErrorToast(message: "Error parsing dates. Please re-select.");
      return;
    }

    // 6. Proceed to API call
    _callApi();
  }

  Future<void> _callApi() async {
    Map<String, dynamic> body = {
      'driversLicenseNumber': licenseNoController.text.trim(),
      'issuedOn': issuedOnController.text.trim(),
      'licenceType': licenseTypeController.text.trim(),
      'dob': dobController.text.trim(),
      'nationality': nationalityController.text.trim(),
      'expiryDate': expiryController.text.trim(),
    };

    // Show loading state here if you have a loader helper
    var response = await ApiProvider().licenseAddApi(
      body,
      licenseFront.value!,
      licenseBack.value!,
    );

    if (response.success == true) {
      if (Get.arguments?['from'] == 'edit') {
        Get.back();
      } else {
        Get.toNamed(AppRoutes.vehicleDetail);
      }
    } else {
      Utils.showErrorToast(message: response.message ?? "Update failed");
    }
  }

  @override
  void onClose() {
    // Clean up controllers
    licenseNoController.dispose();
    issuedOnController.dispose();
    licenseTypeController.dispose();
    dobController.dispose();
    nationalityController.dispose();
    expiryController.dispose();
    super.onClose();
  }
}