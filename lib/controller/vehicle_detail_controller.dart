import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../model/types_vehicle_response.dart';
import '../../common/apputills.dart';
import '../../common/camera_helper.dart';
import '../../network/api_provider.dart';

class VehicleDetailController extends GetxController implements CameraOnCompleteListener {
  late CameraHelper cameraHelper;
  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;

  final isPetsAllowed = false.obs;
  final isLargeVehicle = false.obs;
  // Data Lists
  RxList<VehicleTypes> vehicleTypes = RxList();
  final vehicleModelController = TextEditingController();
  final vehicleColorController = TextEditingController();

  // Image Observables
  final vehicleImage = RxnString();
  final registrationImage = RxnString();
  final insuranceImage = RxnString();

  // Selected Vehicle Object
  Rxn<VehicleTypes> selectedVehicleType = Rxn<VehicleTypes>();

  // Text Controllers
  final registrationExpiryController = TextEditingController();
  final insuranceExpiryController = TextEditingController();
  final vehicleNumberController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    cameraHelper = CameraHelper(this);
    getTypesOfVehicle();
  }

  @override
  void onSuccessFile(String file, String fileType, int code) {
    if (file.isNotEmpty) {
      if (code == 1) vehicleImage.value = file;
      if (code == 2) registrationImage.value = file;
      if (code == 3) insuranceImage.value = file;
    }
  }

  @override
  void onSuccessVideo(String selectedUrl, Uint8List? thumbnail) {}

  Future<void> getTypesOfVehicle() async {
    var response = await ApiProvider().typeVehicle();
    if (response.success == true) {
      vehicleTypes.assignAll(response.body ?? []);
    }
  }

  Future<void> submitDetails({required Function onSuccess}) async {
    // --- STEP-BY-STEP TOP-TO-BOTTOM VALIDATION ---

    // 1. Picture of Vehicle (Top of screen)
    if (vehicleImage.value == null) {
      Utils.showErrorToast(message: "Please upload a Picture of the Vehicle.");
      return;
    }

   /* // 2. Type of Vehicle (Dropdown)
    if (selectedVehicleType.value == null) {
      Utils.showErrorToast(message: "Please select a Vehicle Type.");
      return;
    }*/

    // 3. Picture of Registration
    if (registrationImage.value == null) {
      Utils.showErrorToast(message: "Please upload the Vehicle Registration image.");
      return;
    }

    // 4. Registration Expiry Date (Empty check)
    if (registrationExpiryController.text.isEmpty) {
      Utils.showErrorToast(message: "Please select Registration Expiry Date.");
      return;
    }

    // 5. Insurance Policy Image
    if (insuranceImage.value == null) {
      Utils.showErrorToast(message: "Please upload the Insurance Policy image.");
      return;
    }

    // 6. Insurance Expiry Date (Empty check)
    if (insuranceExpiryController.text.isEmpty) {
      Utils.showErrorToast(message: "Please select Insurance Expiry Date.");
      return;
    }

    String vModel = vehicleModelController.text.trim();
    if (vModel.isEmpty) {
      Utils.showErrorToast(message: "Please enter your Vehicle Model.");
      return;
    }

    String vColor = vehicleColorController.text.trim();
    if (vColor.isEmpty) {
      Utils.showErrorToast(message: "Please enter your Vehicle Color.");
      return;
    }

    // 7. Vehicle Number (Regex & Empty check)
    String vNumber = vehicleNumberController.text.trim();
    if (vNumber.isEmpty) {
      Utils.showErrorToast(message: "Please enter your Vehicle Number.");
      return;
    }
    // Specific Regex: Only allows Alphanumeric and Hyphens (Standard License Plate Format)
    if (!RegExp(r'^[a-zA-Z0-9\- ]+$').hasMatch(vNumber)) {
      Utils.showErrorToast(message: "Invalid Vehicle Number. Use only letters and numbers.");
      return;
    }
    if (vNumber.length < 4) {
      Utils.showErrorToast(message: "Vehicle Number must be at least 4 characters.");
      return;
    }

    // 8. Logical Date Validation (Documents must not be expired)
    try {
      DateFormat format = DateFormat('yyyy-MM-dd');
      DateTime regDate = format.parse(registrationExpiryController.text);
      DateTime insDate = format.parse(insuranceExpiryController.text);
      DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

      if (regDate.isBefore(today)) {
        Utils.showErrorToast(message: "Your Registration has already expired.");
        return;
      }
      if (insDate.isBefore(today)) {
        Utils.showErrorToast(message: "Your Insurance has already expired.");
        return;
      }
    } catch (e) {
      Utils.showErrorToast(message: "Invalid date selected.");
      return;
    }

    isLoading.value = true;
    String vehicleId = "0";

    if (isLargeVehicle.value) {
      final matchedVehicle = vehicleTypes.firstWhere(
            (vehicle) => vehicle.name!.toUpperCase().contains('XL'),
        orElse: () => vehicleTypes.first,
      );
      vehicleId = matchedVehicle.id ?? "0";
    } else {
      final matchedVehicle = vehicleTypes.firstWhere(
            (vehicle) => !vehicle.name!.toUpperCase().contains('XL'),
        orElse: () => vehicleTypes.first,
      );

      vehicleId =  matchedVehicle.id ?? "0";
    }
    Map<String, dynamic> body = {
      'typeOfVehicleId': vehicleId,
      // 'typeOfVehicleId': selectedVehicleType.value?.id,
      'registrationExpiryDate': registrationExpiryController.text.trim(),
      'insuranceExpiryDate': insuranceExpiryController.text.trim(),
      'vehicleNumber': vNumber,
      'vehicleModel': vehicleModelController.text.trim(),
      'vehicleColor': vehicleColorController.text.trim(), 
      'petsAllowed': isPetsAllowed.value ? 1 : 0,
      'sixPlusSeats': isLargeVehicle.value ? 1 : 0,
    };

    var response = await ApiProvider().vehicleAddApi(
      body,
      vehicleImage.value!,
      registrationImage.value!,
      insuranceImage.value!,
    );

    isLoading.value = false;

    if (response.success == true) {
      onSuccess();
    } else {
      Utils.showErrorToast(message: response.message ?? "Submission failed");
    }
  }

  @override
  void onClose() {
    registrationExpiryController.dispose();
    insuranceExpiryController.dispose();
    vehicleNumberController.dispose();
    vehicleModelController.dispose();
    vehicleColorController.dispose();
    super.onClose();
  }
}