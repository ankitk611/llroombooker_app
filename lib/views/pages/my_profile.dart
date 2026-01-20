import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:roombooker/core/constants/values.dart';
import 'package:roombooker/widgets/app_drawer.dart';
import 'package:roombooker/widgets/navbar_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white, // 👈 back button color
          ),
          elevation: 1,
          backgroundColor: const Color.fromARGB(255, 24, 0, 112),
          // ignore: deprecated_member_use
          shadowColor: Colors.black.withOpacity(0.05),
          titleSpacing: 24,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'My Profile',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),                  
                ],
              ),
              const SizedBox(height: 2),
              
            ],
          ),
          centerTitle: false,
        ),
        drawer: const AppDrawer(currentIndex: 4),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profileHeader(context),
            const SizedBox(height: 24),

            isMobile
                ? Column(
                    children: [
                      _profileInfoCard(),
                      const SizedBox(height: 16),
                      _quickActionsCard(),
                      const SizedBox(height: 16),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _profileInfoCard(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _quickActionsCard(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _profileHeader(BuildContext context) {
  final isMobile = MediaQuery.of(context).size.width < 360;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      /// TOP ROW: Avatar + Name
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.user,
                color: AppColors.primary,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Riya Kumari",
                  style: Styles.blueTitleTextStyle(fontSize: 22),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Manage your account information",
                  style: AppText.secondary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),

      const SizedBox(height: 16),

      /// ACTION BUTTONS
      isMobile
          ? Row(
           // mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: _headerButton(
                    icon: Icons.edit,
                    label: "Edit Profile",
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _headerButton(
                    icon: Icons.key,
                    label: "Change Password",
                    
                    onTap: () {},
                  ),
                ),
              ],
            )
          : Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _headerButton(
                    icon: Icons.edit,
                    label: "Edit Profile",
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                  _headerButton(
                    icon: Icons.key,
                    label: "Change Password",
                    onTap: () {},
                  ),
                ],
              ),
            ),
    ],
  );
}


  // ---------------- PROFILE INFO ----------------
  Widget _profileInfoCard() {
    return _card(
      title: "Profile Information",
      child: Column(
        children: const [
          _infoRow("Full Name", "Riya Kumari"),
          _infoRow("Email", "riya.kumari@linfo.listenlights.com"),
          _infoRow("Role", "User"),
          _infoRow("Member Since", "January 6, 2026"),
        ],
      ),
    );
  }

  // ---------------- QUICK ACTIONS ----------------
  Widget _quickActionsCard() {
    return _card(
      title: "Quick Actions",
      child: Column(
        children: [
          _actionButton(
            FontAwesomeIcons.plus,
            "New Booking",
            AppColors.primary,
          ),
          const SizedBox(height: 12),
          _actionButton(
            FontAwesomeIcons.calendarDay,
            "View Calendar",
            AppColors.success,
          ),
          const SizedBox(height: 12),
          _actionButton(
            FontAwesomeIcons.key,
            "Change Password",
            AppColors.primary,
          ),
        ],
      ),
    );
  }

  // ---------------- STATS ----------------
 

  // ---------------- REUSABLE UI ----------------
  Widget _card({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.cardTitle),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _headerButton({
    required IconData icon,
    
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.primary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: FaIcon(icon, size: 14),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.12),
          foregroundColor: color,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

// ---------------- INFO ROW ----------------
class _infoRow extends StatelessWidget {
  final String label;
  final String value;

  const _infoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppText.secondary),
          Text(value, style: AppText.primary),
        ],
      ),
    );
  }
}
