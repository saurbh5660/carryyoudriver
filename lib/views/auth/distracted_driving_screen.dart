import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/driver_acceptance_controller.dart';
import '../../routes/app_routes.dart';

class DistractedDrivingScreen extends StatelessWidget {
  const DistractedDrivingScreen({super.key});

  static const List<String> clauses = [
    'I will use a hands-free mount for my phone at all times while driving.',
    'I will not hold, type, or read from a phone while the vehicle is in motion.',
    'I will not wear headphones or earbuds in both ears while driving.',
    'I will pull off the road to a safe area if I need to interact with the app beyond a single tap or voice command.',
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DriverAcceptanceController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Step 5 of 6',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Distracted Driving Policy',
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              // Text(
              //   'Version 1.0 · Effective [date]',
              //   style: GoogleFonts.montserrat(
              //     fontSize: 13,
              //     color: Colors.grey.shade600,
              //   ),
              // ),
              const SizedBox(height: 16),


              // Main Policy Checkbox
              Obx(
                () => InkWell(
                  onTap: () {
                    controller.isDistractedPolicyAccepted.value =
                        !controller.isDistractedPolicyAccepted.value;
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: controller.isDistractedPolicyAccepted.value,
                            activeColor: const Color(0xFF00897B),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) {
                              controller.isDistractedPolicyAccepted.value = val ?? false;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'I have read and agree to the Distracted Driving Policy dated [date].',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'I specifically acknowledge that:',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),

              // 4 Sub-acknowledgements List
              Expanded(
                child: ListView.separated(
                  itemCount: clauses.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return Obx(
                      () => InkWell(
                        onTap: () {
                          controller.toggleSubAcknowledgement(
                            index,
                            !controller.subAcknowledgements[index],
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: controller.subAcknowledgements[index],
                                  activeColor: const Color(0xFF00897B),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  onChanged: (val) {
                                    controller.toggleSubAcknowledgement(index, val ?? false);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  clauses[index],
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    color: Colors.black87,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Primary Button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.isDistractedPolicyFullyAcknowledged
                          ? const Color(0xFF00897B)
                          : Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: controller.isDistractedPolicyFullyAcknowledged
                        ? () => Get.toNamed(AppRoutes.driverEsignature)
                        : null,
                    child: Text(
                      'Acknowledge and continue',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: controller.isDistractedPolicyFullyAcknowledged
                            ? Colors.white
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
