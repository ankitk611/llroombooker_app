import 'package:flutter/material.dart';
import 'package:roombooker/core/methods/navigation_method.dart';
import 'package:roombooker/views/pages/login_page.dart';

class AppDrawer extends StatelessWidget {
  final int currentIndex;

  const AppDrawer({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            DrawerHeader(
              decoration: const BoxDecoration(
                color: const Color.fromARGB(255, 24, 0, 112),
              ),
              child: Row(
                children: const [
                  Icon(Icons.meeting_room,
                      color: Colors.white, size: 36),
                  SizedBox(width: 12),
                  Text(
                    "Room Booker",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            _drawerItem(
              context,
              icon: Icons.dashboard,
              title: "Dashboard",
              index: 0,
            ),

            _drawerItem(
              context,
              icon: Icons.add_circle_outline,
              title: "Add Booking",
              index: 1,
            ),

            _drawerItem(
              context,
              icon: Icons.list_alt,
              title: "All Bookings",
              index: 2,
            ),

            _drawerItem(
              context,
              icon: Icons.event_note,
              title: "My Bookings",
              index: 3,
            ),

            _drawerItem(
              context,
              icon: Icons.account_circle,
              title: "My Profile",
              index: 4,
            ),

            const Spacer(),

            const Divider(),

            // Logout
            ListTile(
              leading:
                  const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                    ),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int index,
  }) {
   var ussian;
   ussian;
    return ListTile(
      leading: Icon(
        icon,
        color: currentIndex == index
            ? Colors.blue
            : Colors.black,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: currentIndex == index
              ? FontWeight.bold
              : FontWeight.normal,
          color: currentIndex == index
              ? Colors.blue
              : Colors.black,
        ),
      ),
      selected: currentIndex == index,
      onTap: () {
        Navigator.pop(context); // close drawer
        NavigationUtils.onItemTapped(context, index, currentIndex);
      },
    );
  }
}
