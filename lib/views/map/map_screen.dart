import 'package:cached_network_image/cached_network_image.dart';
import 'package:carry_you_driver/controller/map_route_controller.dart';
import 'package:carry_you_driver/network/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/apputills.dart';
import '../../generated/assets.dart';
import '../../routes/app_routes.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapRouteController controller = Get.put(MapRouteController());
  bool _isTripStarted = false;

  Future<void> _launchNavigation() async {
    final destination = controller.requestBody.value.status == 1
        ? controller.pickupLatLng
        : controller.dropOffLatLng;
    final String googleMapsUrl =
        "google.navigation:q=${destination.latitude},${destination.longitude}";
    final String appleMapsUrl =
        "https://maps.apple.com/?daddr=${destination.latitude},${destination.longitude}";

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else if (await canLaunchUrl(Uri.parse(appleMapsUrl))) {
      await launchUrl(Uri.parse(appleMapsUrl));
    } else {
      Utils.showErrorToast(message: "Could not launch navigation map");
    }
  }

  @override
  void initState() {
    super.initState();
    controller.getBookingDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Obx(() {
            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  controller.latitude.value,
                  controller.longitude.value,
                ),
                zoom: 13,
              ),
              onMapCreated: (mapController) =>
                  controller.mapController = mapController,
              polylines: controller.polylines.toSet(),
              markers: {
                Marker(
                  markerId: MarkerId('driver'),
                  position: LatLng(
                    controller.latitude.value,
                    controller.longitude.value,
                  ),
                  anchor: const Offset(0.5, 0.5),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                  rotation: controller.heading.value,
                ),
                if (controller.requestBody.value.status == 1) ...{
                  Marker(
                    markerId: const MarkerId('pickup'),
                    position: controller.pickupLatLng,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    ),
                  ),
                } else ...{
                  Marker(
                    markerId: const MarkerId('dropOff'),
                    position: controller.dropOffLatLng,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    ),
                  ),
                },
              },
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            );
          }),

          // 2. Floating Header (Address Card)
          _buildFloatingHeader(),

          // 3. Navigate Button (Floating above Bottom Sheet)
          Positioned(
            bottom: 340, // Adjust this based on your bottom sheet height
            left: 20,
            child: GestureDetector(
              onTap: _launchNavigation,
              child: Container(
                height: 60,
                width: 60,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.navigation,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),

          // 4. Bottom Sheet
          _buildBottomSheet(),
        ],
      ),
    );
  }

  Widget _buildFloatingHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircularButton(
                  Icons.arrow_back,
                  () => Navigator.pop(context),
                ),
                Text(
                  "Route Details",
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 45),
              ],
            ),
            const SizedBox(height: 15),
            Obx(() {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      controller.requestBody.value.status == 1
                          ? "Pickup Location"
                          : "Drop Off Location",
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.requestBody.value.status == 1
                          ? (controller.requestBody.value.pickUpLocation ?? "")
                          : (controller.requestBody.value.destinationLocation ??
                                ""),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Obx(() {
      return SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: CachedNetworkImage(
                        imageUrl:
                            ApiConstants.userImageUrl +
                            (controller
                                    .requestBody
                                    .value
                                    .user
                                    ?.profilePicture ??
                                ""),
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            width: 48,
                            height: 48,
                            color: Colors.white,
                          ),
                        ),
                        errorWidget: (context, error, stackTrace) {
                          return Image.asset(
                            Assets.imagesImagePlaceholder,
                            fit: BoxFit.cover,
                            width: 48,
                            height: 48,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.requestBody.value.user?.fullName ?? "",
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            "Order No: #${controller.requestBody.value.id}",
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "Total: \$${controller.requestBody.value.amount}",
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // Text("Delivery: Packet", style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    _buildActionCircle(
                      _isTripStarted ? Icons.call : Icons.chat_bubble_outline,
                      _isTripStarted ? Colors.black : const Color(0xFF4CAF50),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Distance: ${controller.distance}",
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          "Est. Time: ${controller.duration}",
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.red.shade400,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.notifications_active,
                            color: Colors.red.shade400,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "SOS",
                            style: GoogleFonts.montserrat(
                              color: Colors.red.shade400,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                controller.requestBody.value.status != 1
                    ? _buildStartedActions()
                    : _buildInitialActions(),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildInitialActions() {
    return Row(
      children: [
        Expanded(
          child: _buildButton("Start", Colors.black, Colors.white, () {
            controller.updateStatus("4");
          }),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildButton("Cancel", Colors.red, Colors.white, () {
            controller.updateStatus("7");
          }),
        ),
      ],
    );
  }

  Widget _buildStartedActions() {
    return Row(
      children: [
        Expanded(
          child: _buildButton("I am Here", Colors.black, Colors.white, () {
            controller.updateStatus("5");
          }),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildButton("Complete", Colors.green, Colors.white, () {
            controller.updateStatus("6");
          }),
        ),
      ],
    );
  }

  Widget _buildCircularButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildActionCircle(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildButton(
    String text,
    Color bg,
    Color textColor,
    VoidCallback onTap,
  ) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.montserrat(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void showDeliveryCodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Title
                Text(
                  "Enter the delivery code",
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30),

                // 2. OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCodeBox(context),
                    _buildCodeBox(context),
                    _buildCodeBox(context),
                    _buildCodeBox(context),
                  ],
                ),
                const SizedBox(height: 35),

                // 3. Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Get.toNamed(AppRoutes.paymentStatus);
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Submit",
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCodeBox(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: TextField(
          onChanged: (value) {
            if (value.length == 1) {
              FocusScope.of(context).nextFocus();
            }
          },
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: "", // Removes the character counter
            hintText: "-",
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
