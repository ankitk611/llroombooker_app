import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:roombooker/views/pages/all_bookings_page.dart';


class AppBottomNavbar extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavbar({
    super.key,
    required this.currentIndex,
  });

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = AllBookings();
        break;
      case 1:
        page = AllBookings();
        break;
      case 2:
        page = AllBookings();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35), // 🔵 high curve
          border: Border.all(
            color: const Color.fromARGB(115, 82, 148, 247),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(
              icon: FontAwesomeIcons.gaugeHigh,
              label: 'Dashboard',
              index: 0,
              context: context,
            ),

            // 🔵 Center Add Button
            GestureDetector(
              onTap: () => _onItemTapped(context, 1),
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  FontAwesomeIcons.plus,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),

            _navItem(
              icon: FontAwesomeIcons.clipboardList,
              label: 'Bookings',
              index: 2,
              context: context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
    required BuildContext context,
  }) {
    final bool isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () => _onItemTapped(context, index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected ? const Color.fromARGB(255, 0, 73, 133) : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? const Color.fromARGB(255, 1, 78, 141) : Colors.grey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
