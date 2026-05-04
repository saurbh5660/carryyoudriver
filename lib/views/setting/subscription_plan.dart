import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';
import '../../common/revenuecat_subscription.dart';
import '../../controller/subscription_controller.dart';

class SubscriptionPlanScreen extends StatefulWidget {
  const SubscriptionPlanScreen({super.key});

  @override
  State<SubscriptionPlanScreen> createState() => _SubscriptionPlanScreenState();
}

class _SubscriptionPlanScreenState extends State<SubscriptionPlanScreen> {
  final controller = Get.put(SubscriptionController());

  List<Package?> packages = [];
  int selectedPlanIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPackages();
    // controller.getUserSubscription();
  }

  Future<void> fetchPackages() async {
    try {
      final offerings = await PurchaseApi.fetchOffers();

      if (offerings.isNotEmpty) {
        packages = offerings.first.availablePackages;
      }
      log("Packages length: ${packages.length}");
    } catch (e, s) {
      log("fetchPackages error: $e", stackTrace: s);
    }
    // await controller.getUserSubscription();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        title: Text(
          'Subscription Plan',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    /// FREE PLAN
                    _buildPlanCard(
                      index: 0,
                      label: "Free",
                      labelBgColor: const Color(0xFFF7941D),
                      features: const ["Standard Access", "Limited content"],
                      price: "Free (1 Month)",
                    ),
                    const SizedBox(height: 20),

                    /// PREMIUM PLAN
                    if (packages.isNotEmpty)
                      _buildPlanCard(
                        index: 1,
                        label: "Premium",
                        labelBgColor: const Color(0xFFF7941D),
                        price:
                            '${packages.first?.storeProduct.priceString ?? ""}/Monthly',
                        features: const [
                          "Exclusive Videos",
                          "Live Event Streaming",
                        ],
                        // features: [
                        //   packages.first
                        //       ?.storeProduct.description ??
                        //       ""
                        // ],
                      ),

                    const Spacer(),

                    /// BUY BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onBuyPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF7941D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Buy Now",
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> onBuyPressed() async {
    bool isPremiumSelected = selectedPlanIndex == 1;

    if (isPremiumSelected) {
      if (packages.isNotEmpty) {
        await PurchaseApi.buyPlan(
          package: packages.first,
          screenType: "1",
          timeDuration: "2",
        );
      }
    } else {
      // if ((Get.arguments?["from"] ?? "") == "signup") {
      //   controller.updateFreeSubscription();
      // } else {
      //   Get.back();
      // }
    }
  }

  Widget _buildPlanCard({
    required int index,
    required String label,
    required Color labelBgColor,
    required List<String> features,
    required String price,
  }) {
    bool isSelected = selectedPlanIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlanIndex = index;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFF7941D) : Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 50,
                decoration: BoxDecoration(
                  color: labelBgColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(11),
                    bottomLeft: Radius.circular(11),
                  ),
                ),
                child: Center(
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      label,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            price,
                            style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color: isSelected
                                ? const Color(0xFFF7941D)
                                : Colors.grey.shade300,
                            size: 28,
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Exp:",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...features.map(
                        (feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            children: [
                              const Icon(Icons.double_arrow_rounded, size: 14),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
