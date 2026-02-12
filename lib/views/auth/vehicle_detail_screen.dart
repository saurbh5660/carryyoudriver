import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../common/textform_field.dart';
import '../../controller/vehicle_detail_controller.dart';
import '../../model/types_vehicle_response.dart';
import '../../generated/assets.dart';
import '../../routes/app_routes.dart';

class VehicleDetailScreen extends StatefulWidget {
  const VehicleDetailScreen({super.key});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  final VehicleDetailController controller = Get.put(VehicleDetailController());


  Future<void> _selectDate(BuildContext context, TextEditingController textController) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 20),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.black, onPrimary: Colors.white, onSurface: Colors.black),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      textController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Get.back()),
        title: Text('Vehicle Information', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.black)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUploadSection("Picture of Vehicle", controller.vehicleImage, 1),
                const SizedBox(height: 20),

                /*_buildLabel("Type of Vehicle"),
                _buildVehicleTypeDropdown(),
                const SizedBox(height: 20),*/

                _buildUploadSection("Picture of Vehicle Registration", controller.registrationImage, 2),
                const SizedBox(height: 20),

                _buildField("Registration Expiry Date", controller.registrationExpiryController, "YYYY-MM-DD", isDate: true),
                const SizedBox(height: 20),

                _buildUploadSection("Insurance Policy", controller.insuranceImage, 3),
                const SizedBox(height: 20),

                _buildField("Insurance Expiry Date", controller.insuranceExpiryController, "YYYY-MM-DD", isDate: true, hasCalendarIcon: true),
                const SizedBox(height: 20),

                _buildSwitchSection(
                    "Pets Allowed",
                    "Can you carry pets in your vehicle?",
                    controller.isPetsAllowed
                ),


                _buildSwitchSection(
                    "6+ Seats",
                    "Does your vehicle have 6 or more seats?",
                    controller.isLargeVehicle
                ),

                _buildField(
                    "Vehicle Model",
                    controller.vehicleModelController,
                    "e.g., Toyota Camry 2024",
                    validator: (v) => v!.isEmpty ? "Please enter vehicle model" : null
                ),
                const SizedBox(height: 20),

                _buildField(
                    "Vehicle Color",
                    controller.vehicleColorController,
                    "e.g., Metallic Silver",
                    validator: (v) => v!.isEmpty ? "Please enter vehicle color" : null
                ),

                _buildField("Vehicle Number", controller.vehicleNumberController, "e.g., ABC-1234",
                    validator: (v) => v!.isEmpty ? "Please enter vehicle number" : null),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (Get.arguments?['from'] == 'edit') {
                        Get.back();
                      } else {
                        controller.submitDetails(onSuccess: () => showSuccessDialog());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    child: Text(
                      Get.arguments?['from'] == 'edit' ? 'Update' : 'Submit',
                      style: GoogleFonts.montserrat(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleTypeDropdown() {
    return Obx(() => DropdownButtonFormField<VehicleTypes>(
      value: controller.selectedVehicleType.value,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: Colors.black)),
      ),
      hint: Text("Select Vehicle Type", style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
      validator: (value) => value == null ? "Please select vehicle type" : null,
      items: controller.vehicleTypes.map((VehicleTypes type) {
        return DropdownMenuItem<VehicleTypes>(value: type, child: Text(type.name ?? ""));
      }).toList(),
      onChanged: (newValue) => controller.selectedVehicleType.value = newValue,
    ));
  }

  Widget _buildField(String title, TextEditingController ctr, String hint, {bool isDate = false, bool hasCalendarIcon = false, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(title),
        GestureDetector(
          onTap: isDate ? () => _selectDate(context, ctr) : null,
          child: AbsorbPointer(
            absorbing: isDate,
            child: CommonTextField(
              controller: ctr,
              hintText: hint,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide:  BorderSide(color: Colors.grey.shade300, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
              ),
              validator: isDate ? (v) => v!.isEmpty ? "Please select date" : null : validator,
              borderSide: true,
              borderRadius: 28,
              borderColor: Colors.grey.shade300,
              suffixIcon: hasCalendarIcon ? const Icon(Icons.calendar_month, color: Colors.black54) : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadSection(String label, RxnString imagePath, int code) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        Obx(() => GestureDetector(
          onTap: () => controller.cameraHelper.openImagePicker(code),
          child: Container(
            width: 100, height: 100,
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
            child: imagePath.value == null
                ? Center(child: Icon(Icons.camera_alt_outlined, color: Colors.grey.shade400, size: 28))
                : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(imagePath.value!), fit: BoxFit.cover)),
          ),
        )),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(text, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black)),
    );
  }

  Widget _buildSwitchSection(String title, String subtitle, RxBool observable) {
    return Obx(() => Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600)),
                Text(subtitle, style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Switch(
            value: observable.value,
            activeColor: Colors.black,
            onChanged: (val) => observable.value = val,
          ),
        ],
      ),
    ));
  }

  void showSuccessDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(Assets.iconsChecked, width: 80, height: 80),
              const SizedBox(height: 24),
              Text("Your details has been submitted successfully, Please wait for admin approval!", textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black, height: 1.5)),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.loginView),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                  child: Text('OK', style: GoogleFonts.montserrat(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}