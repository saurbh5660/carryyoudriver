import 'package:cached_network_image/cached_network_image.dart';
import 'package:carry_you_driver/controller/rating_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../generated/assets.dart';
import '../../network/api_constants.dart';

class RatingScreen extends StatelessWidget {
  RatingScreen({super.key});

  final controller = Get.put(RatingController());
  final TextEditingController _commentController = TextEditingController();

  String _getRatingText(double rating) {
    if (rating == 1) return "Terrible 😠";
    if (rating == 2) return "Disappointing ☹️";
    if (rating == 3) return "Good / Okay 😐";
    if (rating == 4) return "Very Good 😊";
    if (rating == 5) return "Excellent! 😄";
    return "Tap stars to rate your trip";
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
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Submit Rating",
          style: GoogleFonts.montserrat(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          final customer = controller.requestBody.value.user;
          final vehicle = controller.requestBody.value.typeOfVechile;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 1. Customer Info Profile Card
                Container(
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
                            imageUrl: ApiConstants.userImageUrl + (customer?.profilePicture ?? ""),
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Container(width: 64, height: 64, color: Colors.white),
                            ),
                            errorWidget: (context, error, stackTrace) => Image.asset(
                              Assets.images.imagePlaceholder.path,
                              fit: BoxFit.cover,
                              width: 64,
                              height: 64,
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
                              customer?.fullName ?? "Rider Partner",
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              vehicle?.name ?? "Premium Cab",
                              style: GoogleFonts.montserrat(
                                color: Colors.black45,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                /// 2. Interactive Star Rating Card
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  width: double.infinity,
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
                      Text(
                        "How was your customer?",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Your review helps keep our community safe",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Colors.black38,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// Interactive Star Bar
                      _InteractiveStarBar(
                        initialRating: controller.selectedStars.value,
                        onRatingChanged: (value) {
                          controller.selectedStars.value = value;
                        },
                      ),
                      const SizedBox(height: 14),

                      /// Dynamic Text feedback depending on stars count
                      Obx(() {
                        final currentRating = controller.selectedStars.value;
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            _getRatingText(currentRating),
                            key: ValueKey(currentRating),
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: currentRating >= 4
                                  ? const Color(0xFF22C55E)
                                  : (currentRating >= 3 ? const Color(0xFFFFB300) : const Color(0xFFEF4444)),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                /// 3. Review Comments text area
                Text(
                  "Write Comments",
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black.withOpacity(0.05)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _commentController,
                    maxLines: 4,
                    style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: "Add any feedback about the trip here...",
                      hintStyle: GoogleFonts.montserrat(
                        color: Colors.black38,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                /// 4. Submit Action Button
                Obx(() {
                  final loading = controller.isLoading.value;
                  return SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: loading
                          ? null
                          : () {
                              controller.submitRating(
                                rating: controller.selectedStars.value,
                                comment: _commentController.text,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        disabledBackgroundColor: Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              "Submit Review",
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  );
                }),
                const SizedBox(height: 20),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _InteractiveStarBar extends StatefulWidget {
  const _InteractiveStarBar({
    required this.initialRating,
    required this.onRatingChanged,
  });

  final double initialRating;
  final double size = 38;
  final ValueChanged<double> onRatingChanged;

  @override
  State<_InteractiveStarBar> createState() => _InteractiveStarBarState();
}

class _InteractiveStarBarState extends State<_InteractiveStarBar> {
  late double _rating = widget.initialRating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final isFilled = starValue <= _rating;
        return GestureDetector(
          onTap: () {
            setState(() => _rating = starValue.toDouble());
            widget.onRatingChanged(_rating);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 1.0, end: isFilled ? 1.15 : 1.0),
              duration: const Duration(milliseconds: 150),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Icon(
                    isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                    size: widget.size,
                    color: isFilled ? const Color(0xFFFFD700) : Colors.black12,
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}
