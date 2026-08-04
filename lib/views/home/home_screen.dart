import 'dart:ui';
import 'package:carry_you_driver/controller/home_controller.dart';
import 'package:carry_you_driver/model/request_list_response.dart';
import 'package:carry_you_driver/sidebar/side_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Driver has this many seconds to accept a request before it is auto-rejected.
const int kRequestAutoRejectSeconds = 20;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  final HomeController controller = Get.put(HomeController());
  
  late final AnimationController _pulseController;
  late final AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller.getRequests(true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    _radarController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload requests silently without triggering blocking loader spinner
      controller.getRequests(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      drawer: const SideMenuDrawer(),
      body: Obx(() {
        final isOnline = controller.isOnline.value;
        final hasLocation = controller.latitude.value != 0.0;

        return Stack(
          children: [
            /// 1. Map (Always visible in background to look premium and authentic)
            Positioned.fill(
              child: hasLocation
                  ? GoogleMap(
                      key: const ValueKey("home_map_bg"),
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          controller.latitude.value,
                          controller.longitude.value,
                        ),
                        zoom: 16,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      onMapCreated: (GoogleMapController mapController) {
                        controller.mapController = mapController;
                      },
                      markers: {
                        Marker(
                          markerId: const MarkerId("driver"),
                          position: LatLng(
                            controller.latitude.value,
                            controller.longitude.value,
                          ),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            isOnline ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueYellow,
                          ),
                        ),
                      },
                    )
                  : const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                      ),
                    ),
            ),

            /// 2. Dark Overlay / Blur when Offline to create a premium focus state
            if (!isOnline && hasLocation)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    color: Colors.black.withOpacity(0.45),
                  ),
                ),
              ),

            /// 3. Top Floating Address Bar (Glassmorphic)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              right: 16,
              child: _buildFloatingHeader(isOnline),
            ),

            /// 4. Center Animated Radar Ripple
            /// - When Online: Shows a green scanning radar centered on screen (driver marker)
            /// - When Offline: Shows a premium lock/power status panel in the center
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: isOnline
                      ? _buildOnlineRadar()
                      : _buildOfflineCentralCard(),
                ),
              ),
            ),

            /// 5. Requests Overlay List (Online only)
            if (isOnline)
              Positioned(
                bottom: 110,
                left: 16,
                right: 16,
                top: MediaQuery.of(context).padding.top + 90,
                child: _buildRequestListOverlay(),
              ),

            /// 6. Bottom Floating Go Online/Offline Toggle Button
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              left: 20,
              right: 20,
              child: _buildFloatingToggleButton(isOnline),
            ),
          ],
        );
      }),
    );
  }

  /// =========================================================================
  /// FLOATING TOP STATUS & LOCATION HEADER
  /// =========================================================================
  Widget _buildFloatingHeader(bool isOnline) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isOnline ? Colors.white.withOpacity(0.9) : Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isOnline ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              /// Sidebar Menu Trigger
              Builder(
                builder: (ctx) => InkWell(
                  onTap: () => Scaffold.of(ctx).openDrawer(),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isOnline ? const Color(0xFFF3F4F6) : Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.menu_rounded,
                      color: isOnline ? Colors.black87 : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              /// Status and Current Address
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, _) {
                            final scale = 0.8 + (_pulseController.value * 0.4);
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isOnline ? const Color(0xFF22C55E) : const Color(0xFFFFD700),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isOnline ? const Color(0xFF22C55E) : const Color(0xFFFFD700))
                                          .withOpacity(0.5),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isOnline ? "ACTIVE & SEARCHING" : "OFFLINE",
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: isOnline ? const Color(0xFF22C55E) : const Color(0xFFFFD700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Obx(() {
                      final loc = controller.location.value;
                      return Text(
                        loc.isEmpty ? "Locating driver..." : loc,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isOnline ? Colors.black87 : Colors.white,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// =========================================================================
  /// RADAR / PULSE OVERLAYS
  /// =========================================================================
  Widget _buildOnlineRadar() {
    return AnimatedBuilder(
      animation: _radarController,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(260, 260),
          painter: _RadarWavesPainter(
            progress: _radarController.value,
            color: const Color(0xFF22C55E),
          ),
        );
      },
    );
  }

  Widget _buildOfflineCentralCard() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// Pulsing Glowing Core
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, _) {
            final wave = _pulseController.value;
            return Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.25 * wave),
                    blurRadius: 28,
                    spreadRadius: 6 * wave,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.power_settings_new_rounded,
                  size: 40,
                  color: Color(0xFFFFD700),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        Text(
          "You are Offline",
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Go online to start earning",
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  /// =========================================================================
  /// REQUESTS LIST (ONLINE STATE)
  /// =========================================================================
  Widget _buildRequestListOverlay() {
    return Obx(() {
      final requests = controller.requestList;
      if (requests.isEmpty) {
        return _buildSearchingPanel();
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: RefreshIndicator(
          onRefresh: () => controller.getRequests(false),
          color: Colors.black,
          backgroundColor: Colors.white,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final item = requests[index];
              return _PremiumRequestCard(
                key: ValueKey(item.id),
                item: item,
                onAccept: () => controller.acceptReject("1", item.id.toString(), item),
                onDecline: () => controller.acceptReject("2", item.id.toString(), item),
                onTimeout: () {
                  controller.requestList.removeWhere((request) => request.id == item.id);
                }
              );
            },
          ),
        ),
      );
    });
  }

  /// Small floating panel showing scan state with an elegant progress bar
  Widget _buildSearchingPanel() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                /// Pulsing scanning icon
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, _) {
                    final opacity = 0.4 + (_pulseController.value * 0.6);
                    return Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.wifi_tethering_rounded,
                        color: const Color(0xFF22C55E).withOpacity(opacity),
                        size: 20,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Searching for Rides",
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "You are in a high demand location",
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            /// Premium Scanning/Loading Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                height: 5,
                child: LinearProgressIndicator(
                  backgroundColor: const Color(0xFFF3F4F6),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF22C55E)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =========================================================================
  /// BOTTOM TOGGLE ACTION BUTTON
  /// =========================================================================
  Widget _buildFloatingToggleButton(bool isOnline) {
    final String label = isOnline ? "GO OFFLINE" : "GO ONLINE";
    final List<Color> gradient = isOnline
        ? const [Color(0xFF374151), Color(0xFF1F2937)]
        : const [Color(0xFFFFE57F), Color(0xFFFFC107)];
    final Color textColor = isOnline ? Colors.white : Colors.black87;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final t = _pulseController.value;
        return Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: (isOnline ? const Color(0xFF374151) : const Color(0xFFFFC107))
                    .withOpacity(isOnline ? 0.15 : 0.35 * (1.0 - t * 0.25)),
                blurRadius: 12 + (t * 6),
                spreadRadius: 1 + (t * 1.5),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () => controller.isOnlineStatusChange(),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isOnline ? Icons.power_settings_new_rounded : Icons.flash_on_rounded,
                    color: textColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// =========================================================================
/// RADAR WAVES PAINTER
/// =========================================================================
class _RadarWavesPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RadarWavesPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 0; i < 3; i++) {
      final ringProgress = (progress + i * 0.33) % 1.0;
      final radius = ringProgress * maxRadius;
      final opacity = (1.0 - ringProgress) * 0.25;

      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarWavesPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

/// =========================================================================
/// PREMIUM LIGHT REQUEST CARD
/// =========================================================================
class _PremiumRequestCard extends StatefulWidget {
  final RequestBody item;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onTimeout;

  const _PremiumRequestCard({
    super.key,
    required this.item,
    required this.onAccept,
    required this.onDecline,
    required this.onTimeout,
  });

  @override
  State<_PremiumRequestCard> createState() => _PremiumRequestCardState();
}

class _PremiumRequestCardState extends State<_PremiumRequestCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _countdown;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _countdown = AnimationController(
      vsync: this,
      duration: const Duration(seconds: kRequestAutoRejectSeconds),
    );

    _countdown.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_handled) {
        _handled = true;
        _countdown.stop();
        if (mounted) {
          widget.onTimeout();
        }
      }
    });

    final createdAtStr = widget.item.updatedAt;
    if (createdAtStr != null) {
      final createdAt = DateTime.tryParse(createdAtStr)?.toLocal();
      if (createdAt != null) {
        final now = DateTime.now();
        final diff = now.difference(createdAt).inSeconds;

        if (diff >= kRequestAutoRejectSeconds) {
          _handled = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              widget.onTimeout();
            }
          });
        } else if (diff > 0) {
          _countdown.forward(from: diff / kRequestAutoRejectSeconds);
        } else {
          _countdown.forward();
        }
      } else {
        _countdown.forward();
      }
    } else {
      _countdown.forward();
    }
  }

  @override
  void dispose() {
    _countdown.dispose();
    super.dispose();
  }

  void _handleAccept() {
    if (_handled) return;
    _handled = true;
    _countdown.stop();
    widget.onAccept();
  }

  void _handleDecline() {
    if (_handled) return;
    _handled = true;
    _countdown.stop();
    widget.onDecline();
  }

  Color _progressColor(double value) {
    if (value < 0.5) return const Color(0xFF22C55E); // green
    if (value < 0.8) return const Color(0xFFFFB300); // amber
    return const Color(0xFFEF4444); // red
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final amount = item.amount;
    final distance = item.distance;
    final riderName = item.user?.fullName ?? "Rider";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          /// Countdown top bar indicator
          AnimatedBuilder(
            animation: _countdown,
            builder: (context, _) {
              final value = _countdown.value;
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: LinearProgressIndicator(
                  value: 1 - value,
                  minHeight: 4,
                  backgroundColor: const Color(0xFFF3F4F6),
                  valueColor: AlwaysStoppedAnimation<Color>(_progressColor(value)),
                ),
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Passenger Info Row
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          riderName.isNotEmpty ? riderName[0].toUpperCase() : "R",
                          style: GoogleFonts.montserrat(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            riderName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.near_me_rounded, size: 12, color: Colors.black38),
                              const SizedBox(width: 4),
                              Text(
                                item.distanceTxt ?? "Calculating distance...",
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// Countdown Ring
                    _CountdownRing(
                      controller: _countdown,
                      totalSeconds: kRequestAutoRejectSeconds,
                      colorBuilder: _progressColor,
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                /// Price/KM details row
                Row(
                  children: [
                    if (amount != null)
                      _buildInfoBadge(
                        icon: Icons.currency_exchange,
                        label: amount.toStringAsFixed(0),
                        color: const Color(0xFF22C55E),
                      ),
                    if (distance != null) ...[
                      const SizedBox(width: 8),
                      _buildInfoBadge(
                        icon: Icons.directions_car_rounded,
                        label: "${distance.toStringAsFixed(1)} km",
                        color: const Color(0xFF3B82F6),
                      ),
                    ],
                    if (item.scheduleType == 2) ...[
                      const SizedBox(width: 8),
                      _buildInfoBadge(
                        icon: Icons.calendar_today_rounded,
                        label: "Scheduled",
                        color: const Color(0xFFF59E0B),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 14),

                /// Address Route Indicator
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withOpacity(0.03)),
                  ),
                  child: Column(
                    children: [
                      _buildRouteRow(
                        color: const Color(0xFF22C55E),
                        title: "PICKUP LOCATION",
                        address: item.pickUpLocation ?? "N/A",
                      ),
                      _buildRouteSeparator(),
                      _buildRouteRow(
                        color: const Color(0xFFEF4444),
                        title: "DROP-OFF DESTINATION",
                        address: item.destinationLocation ?? "N/A",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// Confirm / Cancel actions
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        onPressed: _handleDecline,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          foregroundColor: Colors.black54,
                        ),
                        child: Text(
                          "Decline",
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        onPressed: _handleAccept,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Accept Ride",
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteRow({
    required Color color,
    required String title,
    required String address,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 10),
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
                  fontSize: 12,
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

  Widget _buildRouteSeparator() {
    return Padding(
      padding: const EdgeInsets.only(left: 3),
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
    );
  }
}

/// =========================================================================
/// CIRCULAR COUNTDOWN RING
/// =========================================================================
class _CountdownRing extends StatelessWidget {
  final AnimationController controller;
  final int totalSeconds;
  final Color Function(double value) colorBuilder;

  const _CountdownRing({
    required this.controller,
    required this.totalSeconds,
    required this.colorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final value = controller.value;
          final remaining = (totalSeconds - (value * totalSeconds)).ceil().clamp(0, totalSeconds);
          final color = colorBuilder(value);

          return Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  value: 1 - value,
                  strokeWidth: 3,
                  backgroundColor: const Color(0xFFF3F4F6),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text(
                "$remaining",
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
