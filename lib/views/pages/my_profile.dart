import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:roombooker/core/constants/values.dart';
import 'package:roombooker/views/pages/all_bookings_page.dart';
import 'package:roombooker/views/pages/create_booking_page.dart';
import 'package:roombooker/widgets/app_drawer.dart';
import 'package:roombooker/widgets/navbar_widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:roombooker/core/constants/url.dart';
import 'package:roombooker/core/methods/token_methods.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? profile;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchMyProfile();
  }

  //fetchmyprofile
  Future<void> fetchMyProfile() async {
    setState(() => isLoading = true);

    try {
      final token = await TokenUtils().getBearerToken();

      final response = await http.get(
        Uri.parse('${Url.baseUrl}/users/myprofile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        setState(() {
          profile = decoded['data']; // 👈 IMPORTANT
        });
      } else {
        setState(() => profile = null);
      }
    } catch (e) {
      setState(() => profile = null);
    } finally {
      setState(() => isLoading = false);
    }
  }

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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : profile == null
          ? const Center(child: Text('Failed to load profile'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _profileHeader(context),
                  const SizedBox(height: 24),

                  Column(
                    children: [
                      _profileInfoCard(), // full width (your card already uses width: double.infinity)
                      const SizedBox(height: 16),
                      _quickActionsCard(), // below the card, full width
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
                    profile!['name'] ?? '-',
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
        children: [
          _infoRow("Full Name", profile!['name'] ?? '-'),
          _infoRow("Email", profile!['email'] ?? '-'),
          _infoRow("Role", profile!['role']?['name'] ?? 'User'),
          _infoRow(
            "Member Since",
            profile!['created_at'] != null
                ? profile!['created_at'].toString().substring(0, 10)
                : '-',
          ),
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateBookingPage()),
              );
            },
          ),
          const SizedBox(height: 12),
          _actionButton(
            FontAwesomeIcons.calendarDay,
            "View Calendar",
            AppColors.success,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AllBookings()),
              );
            },
          ),
          const SizedBox(height: 12),
          _actionButton(
            FontAwesomeIcons.key,
            "Change Password",
            AppColors.primary,
            onPressed: () {
              // Handle notification button press
            },
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _actionButton(
    IconData icon,
    String label,
    Color color, {
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed, // ✅ use the callback
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
        children: [
          // Left label takes remaining space but can shrink
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppText.secondary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),

          // Right value is flexible + truncates safely
          Flexible(
            flex: 3,
            child: Text(
              value,
              style: AppText.primary,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }
}
