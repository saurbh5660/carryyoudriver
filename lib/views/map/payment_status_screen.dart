import 'package:cached_network_image/cached_network_image.dart';
import 'package:carry_you_driver/controller/payment_status_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../generated/assets.dart';
import '../../network/api_constants.dart';
import '../../routes/app_routes.dart';

class PaymentStatusScreen extends StatefulWidget {
  const PaymentStatusScreen({super.key});

  @override
  State<PaymentStatusScreen> createState() => _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends State<PaymentStatusScreen> {
  PaymentStatusController controller = Get.put(PaymentStatusController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.getBookingDetail();
      if (mounted) {
        _showRideCompletedDialog();
      }
    });
  }

  void _showRideCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.85, end: 1.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 36,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Double Ring Success Icon
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF22C55E).withOpacity(0.08),
                    ),
                    child: Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF22C55E).withOpacity(0.3),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Ride Completed!",
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "You have successfully reached the destination.\nWould you like to rate the customer?",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      height: 1.4,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  /// Gold stars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFD700),
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  /// Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey.shade200),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            foregroundColor: Colors.black54,
                          ),
                          child: Text(
                            "Skip",
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            Get.toNamed(
                              AppRoutes.ratingScreen,
                              arguments: {"detail": controller.requestBody.value},
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "Rate Now",
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Payment Details",
          style: GoogleFonts.montserrat(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Obx(() {
            final hasRoute = controller.requestBody.value.pickUpLocation != null;
            if (!hasRoute) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: CircularProgressIndicator(color: Color(0xFFFFD700)),
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 1. Route Timeline panel
                _buildRouteTimeline(),
                const SizedBox(height: 20),

                /// 2. Metrics summary cards
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        value: "\$${controller.requestBody.value.amount ?? '0'}",
                        label: "Total Earnings",
                        gradient: const LinearGradient(
                          colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildSummaryCard(
                        value: "${controller.requestBody.value.distance ?? '0'} km",
                        label: "Distance Covered",
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1F2937), Color(0xFF111827)],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                /// 3. Customer Details Card
                Text(
                  "Customer Details",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                _buildCustomerSection(),
                const SizedBox(height: 32),

                /// 4. Done CTA Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Get.offAllNamed(AppRoutes.homeScreen);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Return to Home",
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildRouteTimeline() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildLocationRow(
            color: const Color(0xFF22C55E),
            title: "PICKUP LOCATION",
            address: controller.requestBody.value.pickUpLocation ?? "N/A",
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                children: List.generate(
                  3,
                  (index) => Container(
                    width: 1.5,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: Colors.black12,
                  ),
                ),
              ),
            ),
          ),
          _buildLocationRow(
            color: const Color(0xFFEF4444),
            title: "DROP-OFF DESTINATION",
            address: controller.requestBody.value.destinationLocation ?? "N/A",
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow({
    required Color color,
    required String title,
    required String address,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String value,
    required String label,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.montserrat(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerSection() {
    final user = controller.requestBody.value.user;
    final rideId = controller.requestBody.value.id;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5), width: 1.5),
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: ApiConstants.userImageUrl + (user?.profilePicture ?? ""),
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(width: 52, height: 52, color: Colors.white),
                ),
                errorWidget: (context, error, stackTrace) => Image.asset(
                  Assets.images.imagePlaceholder.path,
                  fit: BoxFit.cover,
                  width: 52,
                  height: 52,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.fullName ?? "Rider Partner",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "Order No: #${rideId ?? '...'}",
                  style: GoogleFonts.montserrat(
                    color: Colors.black45,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Phone: ${user?.phoneNumber ?? 'N/A'}",
                  style: GoogleFonts.montserrat(
                    color: Colors.black45,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
