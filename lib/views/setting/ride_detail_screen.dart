import 'package:cached_network_image/cached_network_image.dart';
import 'package:carry_you_driver/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer/shimmer.dart';
import '../../controller/ride_detail_controller.dart';
import '../../generated/assets.dart';
import '../../network/api_constants.dart';

class RideDetailScreen extends GetView<RideDetailController> {
  const RideDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Ride Summary",
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.black));
        }

        final data = controller.rideDetail.value;

        // Parse coordinates safely
        double pickLat = double.tryParse(data.pickUpLatitude ?? "0") ?? 0;
        double pickLng = double.tryParse(data.pickUpLongitude ?? "0") ?? 0;
        double destLat = double.tryParse(data.destinationLatitude ?? "0") ?? 0;
        double destLng = double.tryParse(data.destinationLongitude ?? "0") ?? 0;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Map Route Header Card (Safe native maps matching listing styling)
              Container(
                height: 220,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
                  ],
                ),
                child: pickLat != 0 && pickLng != 0 && destLat != 0 && destLng != 0
                    ? IgnorePointer(
                        child: HistoryMapPreview(
                          pickLat: pickLat,
                          pickLng: pickLng,
                          destLat: destLat,
                          destLng: destLng,
                        ),
                      )
                    : Container(
                        color: const Color(0xFFECEFF1),
                        child: const Center(
                          child: Icon(Icons.map_outlined, color: Colors.grey, size: 50),
                        ),
                      ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. Main Title and Status Badge Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${data.user?.fullName ?? "Rider"} ride",
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    controller.formatDate(data.createdAt),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              _buildStatusBadge(data.status?.toInt()),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  "Order No: #${data.id}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "\$${data.amount?.toStringAsFixed(2)}",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 3. User & Vehicle Details Card
                    Text(
                      "Trip details",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          // Rider Profile Info
                          Row(
                            children: [
                              ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: ApiConstants.userImageUrl + (data.user?.profilePicture ?? ""),
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(width: 48, height: 48, color: Colors.white),
                                  ),
                                  errorWidget: (context, error, stackTrace) => Image.asset(
                                    Assets.images.imagePlaceholder.path,
                                    fit: BoxFit.cover,
                                    width: 48,
                                    height: 48,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data.user?.fullName ?? "Rider Info",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      data.user?.phoneNumber ?? "N/A Phone",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          if (data.typeOfVechile != null) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(height: 1),
                            ),
                            // Vehicle Profile Info
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: ApiConstants.userImageUrl + (data.typeOfVechile?.image ?? ""),
                                    width: 38,
                                    height: 38,
                                    fit: BoxFit.contain,
                                    errorWidget: (context, error, stackTrace) => const Icon(
                                      Icons.directions_car_rounded,
                                      color: Colors.grey,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Vehicle Category",
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      data.typeOfVechile?.name ?? "Standard",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ]
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 4. Pickup & Dropoff Timeline Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLocationRow(
                            icon: Icons.trip_origin_rounded,
                            iconColor: const Color(0xFF2E7D32),
                            title: "PICKUP LOCATION",
                            address: data.pickUpLocation,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 7, top: 4, bottom: 4),
                            child: Column(
                              children: List.generate(4, (index) => Container(
                                width: 1.5,
                                height: 3,
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                color: Colors.grey.shade400,
                              )),
                            ),
                          ),
                          _buildLocationRow(
                            icon: Icons.location_on_rounded,
                            iconColor: const Color(0xFFC62828),
                            title: "DROP-OFF LOCATION",
                            address: data.destinationLocation,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 5. Trip Stats (Distance) Card
                    if (data.distance != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.analytics_outlined, color: Colors.blueAccent),
                                const SizedBox(width: 10),
                                Text(
                                  "Total Distance",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "${data.distance} km",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 25),

                    // 6. Help & Safety Section
                    Text(
                      "Help & safety",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: _buildHelpRow(Icons.search, "Lost item", showArrow: true),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(int? status) {
    bool isCanceled = status == 3 || status == 7;
    Color color = isCanceled ? const Color(0xFFC62828) : const Color(0xFF2E7D32);
    Color bgColor = isCanceled ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        isCanceled ? "Canceled" : "Completed",
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildHelpRow(IconData icon, String text, {bool showArrow = false}) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Get.toNamed(AppRoutes.driverLostItemScreen, arguments: {"id": controller.bookingId});
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: Colors.grey[800]),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            if (showArrow) const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
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
      liteModeEnabled: false,
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