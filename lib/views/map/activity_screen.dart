import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/activity_controller.dart';
import '../../model/booking_list_response.dart';
import '../../routes/app_routes.dart';

class ActivityScreen extends GetView<ActivityController> {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    Get.put(ActivityController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text("My Activity",
            style: GoogleFonts.montserrat(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 28)),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2));
        }

        if (controller.ongoingRides.isEmpty && controller.pastRides.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => controller.getBookingList(),
          color: Colors.black,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ACTIVE TASKS SECTION
              if (controller.ongoingRides.isNotEmpty) ...[
                _buildSectionHeader("Active Task"),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildOngoingCard(controller.ongoingRides[index]),
                      childCount: controller.ongoingRides.length,
                    ),
                  ),
                ),
              ],

              // HISTORY SECTION
              _buildSectionHeader("Past Trips"),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildHistoryCard(controller.pastRides[index]),
                    childCount: controller.pastRides.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 12),
        child: Text(title,
            style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black54)),
      ),
    );
  }

  // Large Prominent Card for Ongoing Trip
  Widget _buildOngoingCard(Body item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(20),
            leading: const CircleAvatar(
              backgroundColor: Colors.black,
              child: Icon(Icons.navigation_rounded, color: Colors.white),
            ),
            title: Text(
              controller.getStatusText(item.status),
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, color: Colors.blueAccent),
            ),
            subtitle: Text(
              item.pickUpLocation ?? "Unknown Pickup",
              style: const TextStyle(fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              "₹${item.amount}",
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.toNamed(AppRoutes.mapScreen, arguments: {"bookingId": item.id.toString(), "item": item});
                },
                icon: const Icon(Icons.near_me_rounded),
                label: const Text("RESUME TRIP", style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Simple Row Card for History
  Widget _buildHistoryCard(Body item) {
    bool isCancelled = (item.status == 3 || item.status == 7);

    return GestureDetector(
      onTap: (){
        Get.toNamed(AppRoutes.rideDetailScreen,arguments: {"bookingId":item.id.toString()});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCancelled ? Colors.red[50] : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCancelled ? Icons.close_rounded : Icons.check_circle_outline,
              color: isCancelled ? Colors.red : Colors.grey[700],
            ),
          ),
          title: Text(
            item.pickUpLocation ?? "Trip",
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            "${controller.formatDate(item.createdAt)}\n${controller.getStatusText(item.status)}",
            style: TextStyle(fontSize: 11, color: Colors.grey[600], height: 1.4),
          ),
          trailing: Text(
            "₹${item.amount}",
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: isCancelled ? Colors.grey : Colors.black
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("No activity yet",
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey)),
          const SizedBox(height: 8),
          Text("Your completed trips will appear here",
              style: GoogleFonts.montserrat(color: Colors.grey[500])),
        ],
      ),
    );
  }
}