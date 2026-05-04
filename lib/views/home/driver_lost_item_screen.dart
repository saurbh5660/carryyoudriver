import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/driver_lost_item_controller.dart';
import '../../model/lost_item_request_response.dart';
import '../../routes/app_routes.dart';

class DriverLostItemScreen extends StatefulWidget {
  const DriverLostItemScreen({super.key});

  @override
  State<DriverLostItemScreen> createState() => _DriverLostItemScreenState();
}

class _DriverLostItemScreenState extends State<DriverLostItemScreen> {
  late final DriverLostItemController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(DriverLostItemController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text(
          "Lost Item Requests",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.lostItems.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.black,
              strokeWidth: 2,
            ),
          );
        }

        if (controller.lostItems.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          color: Colors.black,
          onRefresh: () => controller.getLostItemRequests(),
          child: ListView.builder(
            padding: const EdgeInsets.all(15),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.lostItems.length,
            itemBuilder: (context, index) {
              return _buildRequestCard(controller.lostItems[index]);
            },
          ),
        );
      }),
    );
  }

  Widget _buildRequestCard(Body item) {
    bool isConfirmed = item.driverConfirm == 1;
    bool isNotConfirm = item.driverConfirm == 2;
    bool isPaid = item.paymentStatus == 1;
    bool isComplete = item.startNavigationStatus == 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusBadge(item),
              Text(
                "Earning: \$${item.amount ?? 20}",
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Item Details Section
          Text(
            "ITEM DESCRIPTION",
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 10,
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.description ?? "",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),

          const Divider(height: 30),

          // Drop Location Section
          if(isPaid)...[
            Text(
              "RETURN TO",
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 10,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: Colors.redAccent, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.dropLocation ?? "",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],

          // Logic Based Action Buttons
          if (!isConfirmed && !isNotConfirm) ...[
            const Divider(height: 30),
            Text(
              "Did you find this item in your vehicle?",
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        controller.updateItemStatus(item.id!, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "NO",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        controller.updateItemStatus(item.id!, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "YES, I HAVE IT",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ]
          else if (isConfirmed && !isPaid) ...[
            _buildInfoTile(
              Icons.hourglass_empty_rounded,
              Colors.orange,
              "Confirmation sent! Waiting for rider to pay the return fee.",
            ),
          ]
          else if (isPaid && !isComplete) ...[
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Get.toNamed(AppRoutes.lostItemMapScreen,arguments: {"requestId":item.id.toString(),"bookingId":item.booking?.id.toString(), "name":item.user?.fullName ?? "", "picture":item.user?.profilePicture ?? "", "countryCode":item.countryCode ?? "", "phone":item.phoneNumber ?? "","dropLatitude":item.dropLatitude ?? "","dropLongitude": item.dropLongitude ?? "","amount":item.amount ?? ""});
                  controller.getLostItemRequests();
                },
                icon: const Icon(Icons.directions_rounded, color: Colors.white),
                label: const Text(
                  "START NAVIGATION",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ]
            else if (isNotConfirm) ...[
            _buildInfoTile(
              Icons.hourglass_empty_rounded,
              Colors.orange,
              "Thanks for confirming.",
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(Body item) {
    String text = "Pending";
    Color color = Colors.orange;

    if (item.paymentStatus == 1) {
      if(item.startNavigationStatus == 0){
        text = "Ready to Deliver";
      }else if(item.startNavigationStatus == 1){
        text = "Ride Started";
      }else if(item.startNavigationStatus == 3){
        text = "Delivered";
      }
      color = Colors.green;
    } else if (item.driverConfirm == 1) {
      text = "Awaiting Payment";
      color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, Color color, String text) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            "No Active Requests",
            style: GoogleFonts.montserrat(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Any reported lost items will appear here.",
            style: GoogleFonts.montserrat(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
