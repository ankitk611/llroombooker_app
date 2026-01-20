import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String appName;
  final Function() onNotificationsPressed;
  final Function() onProfilePressed;

  // Constructor to pass actions
  CustomAppBar({
    required this.appName,
    required this.onNotificationsPressed,
    required this.onProfilePressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(
            color: Colors.white, // 👈 back button color
          ),
          elevation: 1,
          backgroundColor: const Color.fromARGB(255, 24, 0, 112),
          // ignore: deprecated_member_use
          shadowColor: Colors.black.withOpacity(0.05),
          titleSpacing: 24,
      leading: Padding(
        padding: const EdgeInsets.only(left: 25.0),  // Adjust left padding for alignment
        child: Row(
          children: [
            FaIcon(FontAwesomeIcons.calendarDays, size: 24), // Use FaIcon for FontAwesome icons
            SizedBox(width: 8), // Slightly increase space between the icon and the text
          ],
        ),
      ),
      title: Text(
        appName, // App name
        style: TextStyle(
          fontSize: 22, // Increase font size for better visibility
          fontWeight: FontWeight.bold,
          color: Colors.white, // Ensure text color is black or as desired
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications, size: 28), // Larger icon for better visual impact
          onPressed: onNotificationsPressed,
        ),
        IconButton(
          icon: Icon(Icons.account_circle, size: 28), // Larger profile icon
          onPressed: onProfilePressed,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
