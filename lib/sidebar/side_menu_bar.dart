import 'package:cached_network_image/cached_network_image.dart';
import 'package:carry_you_driver/common/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../common/apputills.dart';
import '../generated/assets.dart';
import '../network/api_constants.dart';
import '../network/api_provider.dart';
import '../routes/app_routes.dart';

class SideMenuDrawer extends StatelessWidget {
  const SideMenuDrawer({super.key});

  Future<void> _handleLogout() async {
    try {
      var response = await ApiProvider().logout();
      if (response.success == true) {
        DbHelper().clearAll();
        Get.offAllNamed(AppRoutes.loginView);
      } else {
        Utils.showErrorToast(message: response.message ?? "Logout failed");
      }
    } catch (e) {
      Utils.showErrorToast(message: "An error occurred: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = Get.currentRoute;
    final user = DbHelper().getUserModel();
    
    return Drawer(
      backgroundColor: const Color(0xFFF9FAFB),
      child: Column(
        children: [
          /// Premium Gradient Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1F2937), Color(0xFF111827)],
              ),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    /// Circular Profile Picture with Double Ring Gold Border
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFFD700).withOpacity(0.6),
                          width: 2.0,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: ApiConstants.userImageUrl + (user?.profilePicture ?? ""),
                            width: 68,
                            height: 68,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Container(
                                width: 68,
                                height: 68,
                                color: Colors.white,
                              ),
                            ),
                            errorWidget: (context, error, stackTrace) {
                              return Image.asset(
                                Assets.images.imagePlaceholder.path,
                                fit: BoxFit.cover,
                                width: 68,
                                height: 68,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    /// Online badge / Verification Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_rounded, color: Color(0xFFFFD700), size: 13),
                          const SizedBox(width: 4),
                          Text(
                            "PARTNER",
                            style: GoogleFonts.montserrat(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFFFD700),
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                /// Full Name
                Text(
                  user?.fullName ?? "Driver Partner",
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),

                /// Email or Subtitle
                Text(
                  "Carry You Driver Partner",
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          /// Navigation List items (highlighted dynamically)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildMenuItem(
                  icon: Icons.home_rounded,
                  title: "Home",
                  type: 1,
                  isActive: currentRoute == AppRoutes.homeScreen,
                ),
                _buildMenuItem(
                  icon: Icons.history_rounded,
                  title: "Ride History",
                  type: 2,
                  isActive: currentRoute == AppRoutes.activityScreen,
                ),
                _buildMenuItem(
                  icon: Icons.account_balance_wallet_rounded,
                  title: "Payment Status",
                  type: 3,
                  isActive: currentRoute == AppRoutes.walletScreen,
                ),
                _buildMenuItem(
                  icon: Icons.notifications_rounded,
                  title: "Notifications",
                  type: 4,
                  isActive: currentRoute == AppRoutes.notificationScreen,
                ),
                _buildMenuItem(
                  icon: Icons.person_rounded,
                  title: "My Profile",
                  type: 5,
                  isActive: currentRoute == AppRoutes.profileScreen,
                ),
                _buildMenuItem(
                  icon: Icons.settings_rounded,
                  title: "Settings",
                  type: 6,
                  isActive: currentRoute == AppRoutes.settingView,
                ),
              ],
            ),
          ),

          /// Logout Option
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: _buildMenuItem(
              icon: Icons.logout_rounded,
              title: "Logout",
              type: 7,
              isLogout: true,
            ),
          ),

          /// Version Info footer
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              "v1.0.0",
              style: GoogleFonts.montserrat(
                fontSize: 10,
                color: Colors.black26,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required int type,
    bool isActive = false,
    bool isLogout = false,
  }) {
    final Color itemColor = isLogout
        ? const Color(0xFFEF4444)
        : (isActive ? Colors.black87 : Colors.black54);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFFFD700).withOpacity(0.12)
            : (isLogout ? const Color(0xFFEF4444).withOpacity(0.06) : Colors.transparent),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? const Color(0xFFFFD700).withOpacity(0.2)
              : Colors.transparent,
          width: 1.0,
        ),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFFFD700).withOpacity(0.2)
                : (isLogout ? const Color(0xFFEF4444).withOpacity(0.1) : Colors.black.withOpacity(0.04)),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isLogout
                ? const Color(0xFFEF4444)
                : (isActive ? const Color(0xFFD4AF37) : Colors.black54),
            size: 18,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: isActive || isLogout ? FontWeight.w800 : FontWeight.w600,
            color: itemColor,
          ),
        ),
        trailing: isLogout
            ? null
            : Icon(
                Icons.chevron_right_rounded,
                color: isActive ? Colors.black38 : Colors.black12,
                size: 16,
              ),
        onTap: () {
          Get.back();
          switch (type) {
            case 1:
              if (Get.currentRoute != AppRoutes.homeScreen) {
                Get.offAllNamed(AppRoutes.homeScreen);
              }
              break;
            case 2:
              Get.toNamed(AppRoutes.activityScreen);
              break;
            case 3:
              Get.toNamed(AppRoutes.walletScreen);
              break;
            case 4:
              Get.toNamed(AppRoutes.notificationScreen);
              break;
            case 5:
              Get.toNamed(AppRoutes.profileScreen);
              break;
            case 6:
              Get.toNamed(AppRoutes.settingView);
              break;
            case 7:
              _handleLogout();
              break;
          }
        },
      ),
    );
  }
}