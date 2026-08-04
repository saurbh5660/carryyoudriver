import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/setting_controller.dart';
import '../../generated/assets.dart';
import '../../routes/app_routes.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final SettingController controller = Get.put(SettingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          /// SECTION 1: Notifications
          _buildSectionHeader("PREFERENCES"),
          _buildCardContainer([
            _buildNotificationTile(Icons.notifications_active_rounded, const Color(0xFFFFD700)),
          ]),
          const SizedBox(height: 20),

          /// SECTION 2: Security & Account
          _buildSectionHeader("SECURITY & ACCOUNT"),
          _buildCardContainer([
            _buildListTile(
              icon: Icons.lock_rounded,
              iconBg: const Color(0xFF3B82F6),
              title: 'Change Password',
              onTap: () => Get.toNamed(AppRoutes.changePasswordScreen),
            ),
            _buildDivider(),
            _buildListTile(
              icon: Icons.person_remove_rounded,
              iconBg: const Color(0xFFF97316),
              title: 'Delete Account',
              onTap: () => showDelete(context),
            ),
          ]),
          const SizedBox(height: 20),

          /// SECTION 3: Legal & Support
          _buildSectionHeader("SUPPORT & LEGAL"),
          _buildCardContainer([
            _buildListTile(
              icon: Icons.support_agent_rounded,
              iconBg: const Color(0xFF10B981),
              title: 'Support and Helpdesk',
              onTap: () => Get.toNamed(AppRoutes.contactScreen),
            ),
            _buildDivider(),
            _buildListTile(
              icon: Icons.privacy_tip_rounded,
              iconBg: const Color(0xFF8B5CF6),
              title: 'Privacy Policy',
              onTap: () => Get.toNamed(AppRoutes.cmsScreen, arguments: {'from': 'privacy'}),
            ),
            _buildDivider(),
            _buildListTile(
              icon: Icons.description_rounded,
              iconBg: const Color(0xFF6B7280),
              title: 'Terms and Conditions',
              onTap: () => Get.toNamed(AppRoutes.cmsScreen, arguments: {'from': 'terms'}),
            ),
          ]),
          const SizedBox(height: 20),

          /// SECTION 4: Session
          _buildSectionHeader("SESSION"),
          _buildCardContainer([
            _buildListTile(
              icon: Icons.logout_rounded,
              iconBg: const Color(0xFFEF4444),
              title: 'Logout',
              showTrailing: false,
              textColor: const Color(0xFFEF4444),
              onTap: () => showLogout(context),
            ),
          ]),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- UI Layout Helpers ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.black38,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCardContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade100,
      indent: 56,
    );
  }

  Widget _buildNotificationTile(IconData icon, Color iconBg) {
    return Obx(() {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: _buildIcon(icon, iconBg),
        title: Text(
          'Notifications',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        trailing: Switch(
          value: controller.isNotificationEnabled.value,
          onChanged: controller.toggleNotification,
          activeThumbColor: const Color(0xFFFFD700),
          activeTrackColor: const Color(0xFFFFD700).withOpacity(0.2),
          inactiveThumbColor: Colors.grey.shade400,
          inactiveTrackColor: Colors.grey.shade200,
        ),
      );
    });
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconBg,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    bool showTrailing = true,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _buildIcon(icon, iconBg),
      title: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: textColor ?? Colors.black87,
        ),
      ),
      trailing: showTrailing
          ? const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.black26)
          : null,
    );
  }

  Widget _buildIcon(IconData icon, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: bgColor, size: 18),
    );
  }

  // --- Dialogs ---

  void showLogout(BuildContext context) {
    _showActionSheet(
      context: context,
      title: "Log Out",
      message: "Are you sure you want to log out of your session?",
      iconPath: Assets.icons.logoutIcon.path,
      onConfirm: () => controller.logout(),
    );
  }

  void showDelete(BuildContext context) {
    _showActionSheet(
      context: context,
      title: "Delete Account",
      message: "Are you sure you want to permanently delete your account? This action cannot be undone.",
      iconPath: Assets.icons.deleteAccount.path,
      onConfirm: () => controller.deleteAccount(),
    );
  }

  void _showActionSheet({
    required BuildContext context,
    required String title,
    required String message,
    required String iconPath,
    required VoidCallback onConfirm,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(iconPath, width: 44, height: 44, color: const Color(0xFFEF4444)),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    color: Colors.black87,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: Colors.black45,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey.shade200),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          foregroundColor: Colors.black54,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel", style: GoogleFonts.montserrat(fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: onConfirm,
                        child: Text("Confirm", style: GoogleFonts.montserrat(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}