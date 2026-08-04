import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Job History",
            style: GoogleFonts.montserrat(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          bottom: TabBar(
            indicatorColor: Colors.black,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            labelStyle: GoogleFonts.montserrat(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

  Widget _buildStatusChip(num? status) {
    String text = "PENDING";
    Color bgColor = const Color(0xFFFFF8E1);
    Color textColor = const Color(0xFFF57F17);

    if (status == 6) {
      text = "COMPLETED";
      bgColor = const Color(0xFFE8F5E9);
      textColor = const Color(0xFF2E7D32);
    } else if (status == 7) {
      text = "CANCELLED";
      bgColor = const Color(0xFFFFEBEE);
      textColor = const Color(0xFFC62828);
    } else if (status == 10 || status == 4 || status == 5 || status == 1) {
      text = "ACTIVE";
      bgColor = const Color(0xFFE3F2FD);
      textColor = const Color(0xFF1565C0);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: textColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildHistoryItemCard(BookingJobHistory item, int currentTab) {
    // Parse Coordinates
    double pickLat = double.tryParse(item.pickUpLatitude ?? "0") ?? 0;
    double pickLng = double.tryParse(item.pickUpLongitude ?? "0") ?? 0;
    double destLat = double.tryParse(item.destinationLatitude ?? "0") ?? 0;
    double destLng = double.tryParse(item.destinationLongitude ?? "0") ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async{
          if (currentTab == 0 || currentTab == 1) {
            await Get.toNamed(AppRoutes.mapScreen, arguments: {"bookingId": item.id, "item": item});
          } else {
            Get.toNamed(AppRoutes.rideDetailScreen, arguments: {"bookingId": item.id});
          }
        },
        child: Column(
          children: [
            // REAL GOOGLE MAP PREVIEW
            Container(
              height: 180,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    if (pickLat != 0 && pickLng != 0 && destLat != 0 && destLng != 0)
                      IgnorePointer(
                        child: HistoryMapPreview(
                          pickLat: pickLat,
                          pickLng: pickLng,
                          destLat: destLat,
                          destLng: destLng,
                        ),
                      )
                    else
                      Container(
                        color: const Color(0xFFECEFF1),
                        child: const Center(
                          child: Icon(Icons.map_outlined, color: Colors.grey, size: 40),
                        ),
                      ),
                    
                    // Detail badge overlays on map
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _buildStatusChip(item.status),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          "\$${item.amount}",
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLocationRow(
                    icon: Icons.trip_origin_rounded,
                    iconColor: const Color(0xFF2E7D32),
                    title: "PICKUP",
                    address: item.pickUpLocation,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 7),
                    child: Container(
                      width: 1.5,
                      height: 20,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  _buildLocationRow(
                    icon: Icons.location_on_rounded,
                    iconColor: const Color(0xFFC62828),
                    title: "DROP-OFF",
                    address: item.destinationLocation,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, color: Colors.grey[600], size: 13),
                          const SizedBox(width: 6),
                          Text(
                            controller.formatDate(item.createdAt),
                            style: GoogleFonts.montserrat(
                              color: Colors.grey[600],
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (item.distance != null)
                        Row(
                          children: [
                            Icon(Icons.directions_car_rounded, color: Colors.grey[700], size: 14),
                            const SizedBox(width: 4),
                            Text(
                              "${item.distance} km",
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildLocationRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String? address,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, color: iconColor, size: 15),
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
                  color: Colors.grey[500],
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address ?? "N/A",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Icon(Icons.history_rounded, size: 50, color: Colors.grey[300]),
        const SizedBox(height: 12),
        Text(
          "No Jobs Found",
          style: GoogleFonts.montserrat(
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class HistoryMapPreview extends StatelessWidget {
  final double pickLat;
  final double pickLng;
  final double destLat;
  final double destLng;

  const HistoryMapPreview({
    super.key,
    required this.pickLat,
    required this.pickLng,
    required this.destLat,
    required this.destLng,
  });

  @override
  Widget build(BuildContext context) {
    final LatLng pickup = LatLng(pickLat, pickLng);
    final LatLng destination = LatLng(destLat, destLng);

    LatLng southwest = LatLng(
      pickLat < destLat ? pickLat : destLat,
      pickLng < destLng ? pickLng : destLng,
    );
    LatLng northeast = LatLng(
      pickLat > destLat ? pickLat : destLat,
      pickLng > destLng ? pickLng : destLng,
    );
    LatLngBounds bounds = LatLngBounds(southwest: southwest, northeast: northeast);

    final double midLat = (pickLat + destLat) / 2;
    final double midLng = (pickLng + destLng) / 2;

    double latDiff = (pickLat - destLat).abs();
    double lngDiff = (pickLng - destLng).abs();
    double maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

    double initialZoom = 14.0;
    if (maxDiff > 0.0) {
      if (maxDiff > 1.0) {
        initialZoom = 8.0;
      } else if (maxDiff > 0.5) {
        initialZoom = 9.0;
      } else if (maxDiff > 0.2) {
        initialZoom = 10.0;
      } else if (maxDiff > 0.1) {
        initialZoom = 11.0;
      } else if (maxDiff > 0.05) {
        initialZoom = 12.0;
      } else if (maxDiff > 0.02) {
        initialZoom = 13.0;
      } else if (maxDiff > 0.01) {
        initialZoom = 14.0;
      } else {
        initialZoom = 15.0;
      }
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(midLat, midLng),
        zoom: initialZoom,
      ),
      liteModeEnabled: false, // Must be false due to Navigation SDK override limits
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      markers: {
        Marker(
          markerId: const MarkerId('pickup'),
          position: pickup,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
        Marker(
          markerId: const MarkerId('destination'),
          position: destination,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      },
      polylines: {
        Polyline(
          polylineId: const PolylineId("route"),
          points: [pickup, destination],
          color: const Color(0xFF1E88E5), // Premium vibrant blue
          width: 4,
          patterns: [
            PatternItem.dash(12),
            PatternItem.gap(8),
          ],
        ),
      },
      onMapCreated: (mapController) {
        // Safe delayed camera bounds adjustment after map layout has loaded
        Future.delayed(const Duration(milliseconds: 150), () {
          try {
            mapController.moveCamera(CameraUpdate.newLatLngBounds(bounds, 36));
          } catch (e) {
            debugPrint("Error updating camera bounds: $e");
          }
        });
      },
    );
  }
}