import 'package:cached_network_image/cached_network_image.dart';
import 'package:carry_you_driver/controller/map_route_controller.dart';
import 'package:carry_you_driver/network/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart' as nav;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/apputills.dart';
import '../../generated/assets.dart';
import '../../routes/app_routes.dart';

/// Driver has this many seconds to accept a request before it is auto-rejected.
const int kRequestAutoRejectSeconds = 20;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapRouteController controller;
  nav.GoogleNavigationViewController? _navigationViewController;
  
  bool _isNavigating = false;
  bool _isSessionInitialized = false;
  nav.LatLng? _lastDestination;

  Worker? _bookingWorker;
  Worker? _locationWorker;
  int? _lastStatus;

  /// Track the bottom sheet extent to dynamically adjust map padding
  double _bottomSheetExtent = 0.42;
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(MapRouteController());
    _initializeNavigation();

    _bookingWorker = ever(controller.requestBody, (body) {
      final newStatus = body.status?.toInt();
      if (_lastStatus != newStatus) {
        _lastStatus = newStatus;
        _updateNavigationDestination();
      }
    });

    _locationWorker = ever<double>(controller.latitude, (_) {
      // Google Navigation handles driver location updates internally
    });

    // Listen to bottom sheet extent changes to update map padding
    _sheetController.addListener(_onSheetChanged);

    if (controller.latitude.value == 0.0 && controller.longitude.value == 0.0) {
      controller.startLocation();
    }
    controller.getBookingDetail();
  }

  void _onSheetChanged() {
    if (_sheetController.isAttached) {
      final newExtent = _sheetController.size;
      if ((newExtent - _bottomSheetExtent).abs() > 0.02) {
        setState(() {
          _bottomSheetExtent = newExtent;
        });
        _updateMapPadding();
      }
    }
  }

  /// Update the map's bottom padding so the route renders above the bottom sheet
  void _updateMapPadding() {
    if (_navigationViewController == null) return;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = screenHeight * _bottomSheetExtent + 24;
    _navigationViewController?.setPadding(
      EdgeInsets.only(top: 80, bottom: bottomPadding),
    );
    // Force camera to center on driver location using the new padding
    _navigationViewController?.followMyLocation(nav.CameraPerspective.tilted);
  }

  Future<void> _initializeNavigation() async {
    try {
      final locationStatus = await ph.Permission.location.request();
      if (!locationStatus.isGranted) {
        Utils.showErrorToast(message: "Location permission is required for navigation.");
        return;
      }

      bool accepted = await nav.GoogleMapsNavigator.areTermsAccepted();
      if (!accepted) {
        accepted = await nav.GoogleMapsNavigator.showTermsAndConditionsDialog(
          "CarryU Driver",
          "Navigation Terms",
        );
      }

      if (accepted == true) {
        debugPrint("Initializing Navigation Session...");
        await nav.GoogleMapsNavigator.initializeNavigationSession();
        
        final isReady = await nav.GoogleMapsNavigator.isInitialized();
        debugPrint("Navigation Session Ready: $isReady");

        if (mounted) {
          setState(() {
            _isSessionInitialized = isReady;
          });
        }
      }
    } catch (e) {
      debugPrint("Error initializing Google Navigation: $e");
      Utils.showErrorToast(message: "Navigation Init Error: $e");
    }
  }

  void _onViewCreated(nav.GoogleNavigationViewController navigationController) {
    _navigationViewController = navigationController;
    
    _navigationViewController?.setMyLocationEnabled(true);
    _navigationViewController?.setNavigationUIEnabled(true);
    _navigationViewController?.setNavigationHeaderEnabled(true);
    _navigationViewController?.setNavigationFooterEnabled(false);
    _navigationViewController?.setNavigationTripProgressBarEnabled(true);
    
    // Apply initial map padding to push route above the bottom sheet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMapPadding();
    });
    
    nav.GoogleMapsNavigator.setOnRemainingTimeOrDistanceChangedListener((event) {
      controller.updateNavProgress(
        event.remainingDistance.toDouble(),
        event.remainingTime.toDouble(),
      );
    });

    _updateNavigationDestination();
  }

  Future<void> _updateNavigationDestination() async {
    if (!_isSessionInitialized || _navigationViewController == null) return;

    final status = controller.requestBody.value.status?.toInt() ?? 1;
    
    // Status 6: Completed, 7: Cancelled
    if (status == 6 || status == 7) {
      await nav.GoogleMapsNavigator.stopGuidance();
      _isNavigating = false;
      _lastDestination = null;
      return;
    }

    final bool goingToDropOff = status >= 10;

    final double destLat = double.tryParse(goingToDropOff 
        ? (controller.requestBody.value.destinationLatitude ?? "0") 
        : (controller.requestBody.value.pickUpLatitude ?? "0")) ?? 0;
    final double destLng = double.tryParse(goingToDropOff 
        ? (controller.requestBody.value.destinationLongitude ?? "0") 
        : (controller.requestBody.value.pickUpLongitude ?? "0")) ?? 0;

    if (destLat == 0 || destLng == 0) return;

    final newDest = nav.LatLng(latitude: destLat, longitude: destLng);

    if (_lastDestination != null &&
        (_lastDestination!.latitude - newDest.latitude).abs() < 0.0001 &&
        (_lastDestination!.longitude - newDest.longitude).abs() < 0.0001) {
      return;
    }

    try {
      final waypoint = nav.NavigationWaypoint(
        title: goingToDropOff ? "Drop-off" : "Pickup",
        target: newDest,
      );

      debugPrint("Setting destination to: ${newDest.latitude}, ${newDest.longitude} (Going to Drop-off: $goingToDropOff)");

      final result = await nav.GoogleMapsNavigator.setDestinations(
        nav.Destinations(
          waypoints: [waypoint],
          displayOptions: nav.NavigationDisplayOptions(
            showDestinationMarkers: true,
            showStopSigns: true,
            showTrafficLights: true,
          ),
          routingOptions: nav.RoutingOptions(
            travelMode: nav.NavigationTravelMode.driving,
            alternateRoutesStrategy: nav.NavigationAlternateRoutesStrategy.none,
          ),
        )
      );

      debugPrint("SetDestinations Result: $result");

      if (result == nav.NavigationRouteStatus.statusOk) {
        await nav.GoogleMapsNavigator.startGuidance();
        
        await _navigationViewController?.setNavigationUIEnabled(true);
        
        _isNavigating = true;
        _lastDestination = newDest;

        _updateMapPadding();
      } else {
        Utils.showErrorToast(message: "Could not calculate route: $result");
      }
    } catch (e) {
      debugPrint("Error setting destination: $e");
    }
  }

  Future<void> _recenterMap() async {
    if (_navigationViewController == null) return;
    try {
      final myLocation = await _navigationViewController!.getMyLocation();
      if (myLocation != null) {
        await _navigationViewController!.followMyLocation(
          nav.CameraPerspective.tilted,
        );
      }
    } catch (e) {
      debugPrint("Error recentering: $e");
    }
  }

  @override
  void dispose() {
    _bookingWorker?.dispose();
    _locationWorker?.dispose();
    _sheetController.removeListener(_onSheetChanged);
    _sheetController.dispose();
    nav.GoogleMapsNavigator.cleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final initialBottomPadding = screenHeight * 0.42 + 24;
    
    return Scaffold(
      body: Stack(
        children: [
          /// 1. Map Viewport
          Positioned.fill(
            child: _isSessionInitialized
                ? nav.GoogleMapsNavigationView(
                    onViewCreated: _onViewCreated,
                    initialNavigationUIEnabledPreference: nav.NavigationUIEnabledPreference.automatic,
                    initialPadding: EdgeInsets.only(top: 80, bottom: initialBottomPadding),
                  )
                : const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                    ),
                  ),
          ),

          /// 2. Floating Header Action
          _buildFloatingHeader(),
          
          /// 3. Recenter overlay button (dynamically offset above bottom sheet)
          _buildRecenterButton(),
          
          /// 4. Sliding bottom control panel
          _buildBottomSheet(),
        ],
      ),
    );
  }

  Widget _buildRecenterButton() {
    return Positioned(
      right: 16,
      bottom: MediaQuery.of(context).size.height * _bottomSheetExtent + 16,
      child: Material(
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.15),
        shape: const CircleBorder(),
        color: Colors.white,
        child: InkWell(
          onTap: _recenterMap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: const Icon(
              Icons.my_location_rounded,
              color: Colors.black87,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingHeader() {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Material(
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.15),
            shape: const CircleBorder(),
            color: Colors.white,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              customBorder: const CircleBorder(),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.black87,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationLine() {
    return Obx(() {
      final status = controller.requestBody.value.status?.toInt() ?? 1;
      final headingToPickup = status < 10;
      final label = headingToPickup ? "PICKUP" : "DROP-OFF";
      final address = headingToPickup
          ? (controller.requestBody.value.pickUpLocation ?? "")
          : (controller.requestBody.value.destinationLocation ?? "");
      final Color statusColor = headingToPickup ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(0.03)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 3),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: statusColor,
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.4),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.montserrat(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBottomSheet() {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.42,
      minChildSize: 0.22,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Top Drag Handle bar
                  Center(
                    child: Container(
                      width: 38,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
          
                  /// Rider Profiling Card
                  Obx(() {
                    final user = controller.requestBody.value.user;
                    final amount = controller.requestBody.value.amount;
                    final rideId = controller.requestBody.value.id;
                    
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black.withOpacity(0.03)),
                      ),
                      child: Row(
                        children: [
                          /// Avatar
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5), width: 1.5),
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: ApiConstants.userImageUrl + (user?.profilePicture ?? ""),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: Container(width: 50, height: 50, color: Colors.white),
                                ),
                                errorWidget: (context, error, stackTrace) => Image.asset(
                                  Assets.images.imagePlaceholder.path,
                                  fit: BoxFit.cover,
                                  width: 50,
                                  height: 50,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
          
                          /// Name & Ride ID & Price info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.fullName ?? "Rider Partner",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  "Order No: #${rideId ?? '...'}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black45,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Total Payment: \$${amount ?? '0'}",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF22C55E),
                                  ),
                                ),
                              ],
                            ),
                          ),
          
                          /// Action Circles
                          _buildActionCircle(
                            icon: Icons.chat_bubble_outline_rounded,
                            color: const Color(0xFF22C55E).withOpacity(0.08),
                            iconColor: const Color(0xFF22C55E),
                            onTap: _openChatWithRider,
                          ),
                          const SizedBox(width: 8),
                          _buildActionCircle(
                            icon: Icons.phone_rounded,
                            color: Colors.black.withOpacity(0.04),
                            iconColor: Colors.black87,
                            onTap: _callRider,
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
          
                  /// Destination Address details
                  _buildLocationLine(),
                  const SizedBox(height: 16),
          
                  /// Time & Distance Metadata
                  Obx(() {
                    return Row(
                      children: [
                        Expanded(
                          child: _buildMetadataCard(
                            icon: Icons.navigation_rounded,
                            title: "DISTANCE",
                            value: controller.distance.value,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMetadataCard(
                            icon: Icons.access_time_filled_rounded,
                            title: "EST. TIME",
                            value: controller.duration.value,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _buildSOSButton(),
                      ],
                    );
                  }),
                  const SizedBox(height: 24),
          
                  /// Action Slide Confirm section
                  Obx(() {
                    final status = controller.requestBody.value.status?.toInt() ?? 1;
                    return _buildActionsForStatus(status);
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetadataCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: Colors.black45),
              const SizedBox(width: 4),
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.black45,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? "..." : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSOSButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final Uri launchUri = Uri(scheme: 'tel', path: '112');
          if (await canLaunchUrl(launchUri)) await launchUrl(launchUri);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.notifications_active_rounded, color: Color(0xFFEF4444), size: 18),
              const SizedBox(width: 4),
              Text(
                "SOS",
                style: GoogleFonts.montserrat(
                  color: const Color(0xFFEF4444),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionsForStatus(int status) {
    Widget primary;
    switch (status) {
      case 1: 
        primary = SlideToConfirmButton(
          key: const ValueKey("status_1"),
          label: "Slide to start trip", 
          onConfirmed: () => controller.updateStatus("4"),
        ); 
        break;
      case 4: 
        primary = SlideToConfirmButton(
          key: const ValueKey("status_4"),
          label: "Slide to confirm arrival", 
          onConfirmed: () => controller.updateStatus("5"),
        ); 
        break;
      case 5: 
        primary = SlideToConfirmButton(
          key: const ValueKey("status_5"),
          label: "Slide to confirm pickup", 
          onConfirmed: () => controller.updateStatus("10"),
        ); 
        break;
      default: 
        primary = SlideToConfirmButton(
          key: const ValueKey("status_default"),
          label: "Slide to complete trip", 
          onConfirmed: () => controller.updateStatus("6"),
        );
    }
    return Column(
      children: [
        primary,
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => _confirmCancel(), 
          child: Text(
            "Cancel ride", 
            style: GoogleFonts.montserrat(
              color: const Color(0xFFEF4444), 
              fontWeight: FontWeight.w800, 
              fontSize: 13,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cancel this ride?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("No")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Yes")),
        ],
      ),
    );
    if (confirmed == true) controller.updateStatus("7");
  }

  Widget _buildActionCircle({
    required IconData icon, 
    required Color color, 
    required Color iconColor, 
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap, 
      child: Container(
        padding: const EdgeInsets.all(12), 
        decoration: BoxDecoration(
          color: color, 
          shape: BoxShape.circle,
        ), 
        child: Icon(icon, color: iconColor, size: 18),
      ),
    );
  }

  void _openChatWithRider() {
    Get.toNamed(AppRoutes.chatScreen, arguments: {
      "id": controller.requestBody.value.user?.id.toString(),
      "name": controller.requestBody.value.user?.fullName?.split(' ').first ?? "",
      "image": controller.requestBody.value.user?.profilePicture.toString(),
    });
  }

  Future<void> _callRider() async {
    String? phone = await controller.callCustomer();
    if (phone != null) {
      final uri = Uri(scheme: 'tel', path: phone);
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    }
  }
}

/// =========================================================================
/// ATTRACTIVE SLIDE TO CONFIRM BUTTON
/// =========================================================================
class SlideToConfirmButton extends StatefulWidget {
  final String label;
  final VoidCallback onConfirmed;

  const SlideToConfirmButton({
    super.key,
    required this.label,
    required this.onConfirmed,
  });

  @override
  State<SlideToConfirmButton> createState() => _SlideToConfirmButtonState();
}

class _SlideToConfirmButtonState extends State<SlideToConfirmButton> with TickerProviderStateMixin {
  double _dragX = 0;
  bool _confirmed = false;
  late final AnimationController _settleController;
  late final AnimationController _textPulseController;

  @override
  void initState() {
    super.initState();
    _settleController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 250),
    )..addListener(() {
        setState(() {
          _dragX = _dragX * (1 - _settleController.value);
        });
      });

    _textPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _settleController.dispose();
    _textPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double trackWidth = constraints.maxWidth;
        const double buttonDiameter = 54;
        const double padding = 4;
        final double maxDragRange = trackWidth - buttonDiameter - (padding * 2);

        return Container(
          height: buttonDiameter + (padding * 2),
          width: trackWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: const Color(0xFFF3F4F6),
            border: Border.all(color: Colors.black.withOpacity(0.04)),
          ),
          child: Stack(
            children: [
              /// Shimmering pulsing text instructions
              Center(
                child: AnimatedBuilder(
                  animation: _textPulseController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: 0.4 + (_textPulseController.value * 0.6),
                      child: child,
                    );
                  },
                  child: Text(
                    widget.label,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Colors.black54,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              /// Dynamic green background showing progress
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: _dragX + (buttonDiameter / 2) + padding,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(32)),
                    color: const Color(0xFF22C55E).withOpacity(0.12),
                  ),
                ),
              ),

              /// Interactive Slide controller
              Positioned(
                left: padding + _dragX,
                top: padding,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_confirmed) return;
                    setState(() {
                      _dragX = (_dragX + details.delta.dx).clamp(0.0, maxDragRange);
                    });
                  },
                  onHorizontalDragEnd: (_) {
                    if (_dragX >= maxDragRange * 0.88) {
                      setState(() {
                        _dragX = maxDragRange; // Push completely to end
                        _confirmed = true;
                      });
                      widget.onConfirmed();
                    } else {
                      _settleController.forward(from: 0);
                    }
                  },
                  child: Container(
                    width: buttonDiameter,
                    height: buttonDiameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.black87,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
