import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/driver_acceptance_controller.dart';
import '../../routes/app_routes.dart';

class DriverTermsScreen extends StatelessWidget {
  const DriverTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DriverAcceptanceController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.termsContent.value.isEmpty && !controller.isTermsLoading.value) {
        controller.fetchLegalContent('driver_terms');
      }
    });

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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Driver Terms of Service',
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
              const SizedBox(height: 12),

              // Scrollable Legal Text Box
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Obx(() {
                    if (controller.isTermsLoading.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(30.0),
                          child: CircularProgressIndicator(color: Colors.black),
                        ),
                      );
                    }

                    final String textToDisplay = controller.termsContent.value.isNotEmpty
                        ? controller.termsContent.value
                        : 'Loading Terms & Conditions...';

                    return SingleChildScrollView(
                      controller: controller.termsScrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Effective Date & Document Header
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        controller.termsTitle.value,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "v${controller.termsVersion.value}",
                                        style: GoogleFonts.montserrat(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Version ${controller.termsVersion.value}. Effective ${controller.termsEffectiveDate.value}",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildFormattedLegalText(textToDisplay),
                          const SizedBox(height: 20),
                          if (controller.hasScrolledTerms.value) ...[
                            Row(
                              children: [
                                const Icon(Icons.check, color: Color(0xFF00897B), size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    "You've reached the end of the document",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF00897B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 12),

              // Action Toolbar (placed below document box per mockup)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        controller.downloadDocument('Driver Terms of Service');
                      },
                      icon: const Icon(Icons.download_rounded, size: 16, color: Colors.black),
                      label: Text(
                        'Download PDF',
                        style: GoogleFonts.montserrat(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        controller.emailDocument('Driver Terms of Service');
                      },
                      icon: const Icon(Icons.email_outlined, size: 16, color: Colors.black),
                      label: Text(
                        'Email to me',
                        style: GoogleFonts.montserrat(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Checkbox Row (Entire row clickable)
              Obx(
                () => InkWell(
                  onTap: () {
                    controller.isTermsAccepted.value = !controller.isTermsAccepted.value;
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
                            value: controller.isTermsAccepted.value,
                            activeColor: const Color(0xFF00897B),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) {
                              controller.isTermsAccepted.value = val ?? false;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'I have read and agree to the Driver Terms of Service dated ${controller.termsEffectiveDate.value}.',
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

              const SizedBox(height: 16),

              // Primary Button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.isTermsAccepted.value
                          ? const Color(0xFF00897B)
                          : Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: controller.isTermsAccepted.value
                        ? () => Get.toNamed(AppRoutes.driverPrivacy)
                        : null,
                    child: Text(
                      'Accept and continue',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: controller.isTermsAccepted.value
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

  Widget _buildFormattedLegalText(String fullText) {
    final sections = fullText.split(RegExp(r'(?=\b\d{1,2}\.\s)'));

    if (sections.length <= 1) {
      return Text(
        fullText,
        style: GoogleFonts.montserrat(
          fontSize: 13.5,
          height: 1.55,
          color: Colors.black87,
          fontWeight: FontWeight.w400,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.map((sec) {
        final trimmed = sec.trim();
        if (trimmed.isEmpty) return const SizedBox.shrink();

        final match = RegExp(r'^(\d{1,2}\.\s[^\n]+)').firstMatch(trimmed);
        if (match != null) {
          final title = match.group(1)!;
          final body = trimmed.substring(title.length).trim();

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            trimmed,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildSectionBody(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 13,
          color: Colors.grey.shade800,
          height: 1.4,
        ),
      ),
    );
  }
}
