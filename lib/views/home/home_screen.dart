import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../sidebar/side_menu_bar.dart';
import '../../controller/home_controller.dart';
import '../../model/request_list_response.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController controller = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    controller.getRequests(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const SideMenuDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Obx(() => Row(
            children: [
              Text(
                controller.isOnline.value ? "Online" : "Offline",
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: controller.isOnline.value ? Colors.green : Colors.grey,
                ),
              ),
              const SizedBox(width: 4),
              Transform.scale(
                scale: 0.7,
                child: CupertinoSwitch(
                  activeColor: Colors.black,
                  value: controller.isOnline.value,
                  onChanged: (value) => controller.isOnlineStatusChange(),
                ),
              ),
              const SizedBox(width: 8),
            ],
          )),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text("Requests", style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 15),
            Expanded(
              child: Obx(() {
                // 1. If Driver is Offline
                if (!controller.isOnline.value) {
                  return _buildOfflinePlaceholder();
                }

                // 2. If Online but no requests
                if (controller.requestList.isEmpty) {
                  return Center(
                    child: Text(
                      "No requests available",
                      style: GoogleFonts.montserrat(color: Colors.grey),
                    ),
                  );
                }

                // 3. If Online with requests
                return RefreshIndicator(
                  onRefresh: () => controller.getRequests(false),
                  color: Colors.black,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    itemCount: controller.requestList.length,
                    itemBuilder: (context, index) => _buildRequestCard(controller.requestList[index]),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflinePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.power_settings_new, size: 80, color: Colors.black12),
          const SizedBox(height: 16),
          Text("You are Offline", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            "Go online to start receiving \nnew ride requests in your area.",
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(RequestBody item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Color(0xFFFFD700), shape: BoxShape.circle),
                    child: const Icon(Icons.location_on, size: 20, color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(item.distanceTxt ?? "...", style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black54)),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Pickup Request", style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 17)),
                    const SizedBox(height: 15),
                    _buildLocationRow("Pickup: ${item.pickUpLocation ?? ""}"),
                    _buildDashedLine(),
                    _buildLocationRow("Drop off: ${item.destinationLocation ?? ""}"),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(child: _buildActionBtn("Decline", Colors.grey.shade100, Colors.black, onTap: () => controller.acceptReject("2", item.id.toString(), item))),
              const SizedBox(width: 12),
              Expanded(child: _buildActionBtn("Accept", Colors.black, Colors.white, onTap: () => controller.acceptReject("1", item.id.toString(), item))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(String address) {
    return Row(
      children: [
        const Icon(Icons.location_on, color: Color(0xFFFFD700), size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(address, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.montserrat(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500))),
      ],
    );
  }

  Widget _buildDashedLine() {
    return Padding(
      padding: const EdgeInsets.only(left: 9),
      child: Column(
        children: List.generate(3, (index) => Container(width: 1.5, height: 4, margin: const EdgeInsets.symmetric(vertical: 2), color: Colors.grey.shade300)),
      ),
    );
  }

  Widget _buildActionBtn(String label, Color bg, Color text, {required VoidCallback onTap}) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(backgroundColor: bg, foregroundColor: text, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        child: Text(label, style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
      ),
    );
  }
}