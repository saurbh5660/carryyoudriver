import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/driver_acceptance_controller.dart';
import '../../routes/app_routes.dart';

class DriverSuccessScreen extends StatelessWidget {
  const DriverSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DriverAcceptanceController>();
    final driverName = controller.legalNameController.text.trim().isEmpty
        ? 'Bassem'
        : controller.legalNameController.text.trim();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Success Icon Badge
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F2F1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF00897B),
                  size: 54,
                ),
              ),
              const SizedBox(height: 28),

              // Welcome Title
              Text(
                "You're all set, $driverName!",
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),

              // Status Subtitle
              Text(
                'Your Driver account is active.',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'A copy of your signed acceptance receipt\nhas been emailed to your registered address.',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Audit Confirmation Code Box
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4FBFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF00897B).withOpacity(0.6),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    controller.confirmationCode.value.isEmpty
                        ? 'CY-DRV-2026-000123'
                        : controller.confirmationCode.value,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: const Color(0xFF00897B),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Primary "Go online" Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00897B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Get.offAllNamed(AppRoutes.homeScreen),
                  child: Text(
                    'Go online',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
