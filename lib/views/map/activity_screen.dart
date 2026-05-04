import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Ensure this is in pubspec
import '../../controller/activity_controller.dart';
import '../../model/booking_history_response.dart';
import '../../routes/app_routes.dart';

class ActivityScreen extends GetView<ActivityController> {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ActivityController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text("Job History",
              style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
          bottom: TabBar(
            indicatorColor: Colors.black,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 13),
            tabs: const [
              Tab(text: "ONGOING"),
              Tab(text: "PENDING"),
              Tab(text: "PAST"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTabListView(0), // Ongoing
            _buildTabListView(1), // Pending
            _buildTabListView(2), // Past
          ],
        ),
      ),
    );
  }

  Widget _buildTabListView(int status) {
    return Obx(() {
      var list = status == 0 ? controller.ongoingList : (status == 1 ? controller.pendingList : controller.pastList);

      if (controller.isLoading.value && list.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: Colors.black));
      }

      // If empty, we wrap in a scrollable view so Pull-to-Refresh still works
      if (list.isEmpty) {
        return RefreshIndicator(
          onRefresh: () async => controller.fetchData(status: status, isRefresh: true),
          color: Colors.black,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: Get.height * 0.3),
              _buildEmptyState(),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async => controller.fetchData(status: status, isRefresh: true),
        color: Colors.black,
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
              controller.fetchData(status: status);
            }
            return false;
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length + (controller.isMoreLoading.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == list.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }
              return _buildHistoryItemCard(list[index], status);
            },
          ),
        ),
      );
    });
  }

  Widget _buildHistoryItemCard(BookingJobHistory item, int currentTab) {
    // Parse Coordinates
    double pickLat = double.tryParse(item.pickUpLatitude ?? "0") ?? 0;
    double pickLng = double.tryParse(item.pickUpLongitude ?? "0") ?? 0;
    double destLat = double.tryParse(item.destinationLatitude ?? "0") ?? 0;
    double destLng = double.tryParse(item.destinationLongitude ?? "0") ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: InkWell(
        onTap: () {
          if (currentTab == 0 || currentTab == 1) {
            Get.toNamed(AppRoutes.mapScreen, arguments: {"bookingId": item.id, "item": item});
          } else {
            Get.toNamed(AppRoutes.rideDetailScreen, arguments: {"bookingId": item.id});
          }
        },
        child: Column(
          children: [
            // REAL GOOGLE MAP PREVIEW
            Container(
              height: 160, // Increased height for better map visibility
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  children: [
                    IgnorePointer( // Prevents user from scrolling inside the map card
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(pickLat, pickLng),
                          zoom: 12,
                        ),
                        liteModeEnabled: true, // Optimizes performance for lists
                        zoomControlsEnabled: false,
                        myLocationButtonEnabled: false,
                        markers: {
                          Marker(markerId: const MarkerId('p'), position: LatLng(pickLat, pickLng)),
                          Marker(markerId: const MarkerId('d'), position: LatLng(destLat, destLng)),
                        },
                        polylines: {
                          Polyline(
                            polylineId: const PolylineId("route"),
                            points: [LatLng(pickLat, pickLng), LatLng(destLat, destLng)],
                            color: Colors.black,
                            width: 3,
                          ),
                        },
                      ),
                    ),
                    Positioned(
                      top: 10, right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)),
                        child: Text("₹${item.amount}",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLocationRow(Icons.circle, Colors.green, item.pickUpLocation),
                  const Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: SizedBox(height: 10, child: VerticalDivider(thickness: 1, color: Colors.grey)),
                  ),
                  _buildLocationRow(Icons.location_on, Colors.red, item.destinationLocation),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(controller.formatDate(item.createdAt),
                          style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                      Text(item.distance != null ? "${item.distance} km" : "",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, Color color, String? location) {
    return Row(
      children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 8),
        Expanded(
          child: Text(location ?? "N/A",
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis)),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Icon(Icons.history_rounded, size: 50, color: Colors.grey[300]),
        const SizedBox(height: 12),
        Text("No Jobs Found",
            style: GoogleFonts.montserrat(color: Colors.grey, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        // const Text("Pull down to refresh", style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}