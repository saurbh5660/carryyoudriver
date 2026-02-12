import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../common/textform_field.dart';
import '../../controller/license_detail_controller.dart';

class LicenseDetailScreen extends StatefulWidget {
  const LicenseDetailScreen({super.key});

  @override
  State<LicenseDetailScreen> createState() => _LicenseDetailScreenState();
}

class _LicenseDetailScreenState extends State<LicenseDetailScreen> {
  final LicenseDetailController controller = Get.put(LicenseDetailController());

  // Helper to handle date selection with logic for DOB (18+ years)
  Future<void> _selectDate(BuildContext context, TextEditingController textController, {bool isDOB = false}) async {
    DateTime now = DateTime.now();
    DateTime eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDOB ? eighteenYearsAgo : now,
      firstDate: DateTime(1950),
      lastDate: isDOB ? eighteenYearsAgo : DateTime(now.year + 50),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      textController.text = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {});
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
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Get.back()
        ),
        title: Text(
            'Licence Detail',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.black)
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: controller.formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel("Licence Photos"),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildUploadBox("Front Side", controller.licenseFront, 1),
                    const SizedBox(width: 16),
                    _buildUploadBox("Back Side", controller.licenseBack, 2),
                  ],
                ),
                const SizedBox(height: 24),

                _buildField(
                    "Licence Number",
                    controller.licenseNoController,
                    "Enter license number",
                    validator: (v) => (v == null || v.isEmpty) ? "License number is required" : null
                ),

                _buildField(
                    "Issued on",
                    controller.issuedOnController,
                    "Select Date",
                    isDatePicker: true
                ),

                _buildLicenseTypeDropdown(),

                _buildField(
                    "Date of Birth",
                    controller.dobController,
                    "Select Date",
                    isDatePicker: true,
                    isDOB: true
                ),

                _buildField(
                    "Nationality",
                    controller.nationalityController,
                    "Enter nationality",
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Nationality is required";
                      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(v)) return "Enter a valid nationality";
                      return null;
                    }
                ),

                _buildField(
                    "Expiry Date",
                    controller.expiryController,
                    "Select Date",
                    isDatePicker: true
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.submitLicenseData(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    child: Text(
                      Get.arguments?['from'] == 'edit' ? 'Update' : 'Next',
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

  // UPDATED: Dropdown with full border
  Widget _buildLicenseTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("License Type"),
          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            onSelected: (val) {
              controller.licenseTypeController.text = val;
              setState(() {});
            },
            itemBuilder: (context) => [
              'LMV-TR (Commercial)',
              'LMV-NT (Private)',
              // 'MCWG (Motorcycle)',
              // 'TRV (Transport Vehicle)',
            ].map((type) => PopupMenuItem(value: type, child: Text(type))).toList(),
            child: AbsorbPointer(
              child: CommonTextField(
                controller: controller.licenseTypeController,
                hintText: "Select Type",
                suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                borderSide: true,
                borderRadius: 28,
                borderColor: Colors.grey.shade300, // Visible Border
                validator: (v) => (v == null || v.isEmpty) ? "Please select license type" : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // UPDATED: Standard Field with full border
  Widget _buildField(String title, TextEditingController ctr, String hint, {bool isDatePicker = false, bool isDOB = false, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(title),
          GestureDetector(
            onTap: isDatePicker ? () => _selectDate(context, ctr, isDOB: isDOB) : null,
            child: AbsorbPointer(
              absorbing: isDatePicker,
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
                validator: isDatePicker ? (v) => (v == null || v.isEmpty) ? "Please select a date" : null : validator,
                borderSide: false,
                borderRadius: 28,
                borderColor: Colors.grey.shade300, // Visible Border
                suffixIcon: isDatePicker ? const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.black54) : null,
              ),
            ),

          ),
        ],
      ),
    );
  }

  Widget _buildUploadBox(String label, RxnString imagePath, int code) {
    return Obx(() => GestureDetector(
      onTap: () => controller.cameraHelper.openImagePicker(code),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
            border: Border.all(color: imagePath.value == null ? Colors.grey.shade300 : Colors.black),
            borderRadius: BorderRadius.circular(12)
        ),

        child: imagePath.value == null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, color: Colors.grey.shade400),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade400, fontSize: 10))
          ],
        )
            : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(imagePath.value!), fit: BoxFit.cover)),
      ),
    ));
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black)),
    );
  }
}