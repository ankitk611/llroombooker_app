import 'package:flutter/material.dart';
import 'package:roombooker/views/pages/all_bookings_page.dart';
import 'package:roombooker/views/pages/create_booking_page.dart';
import 'package:roombooker/views/pages/dashboard_page.dart';
import 'package:roombooker/views/pages/my_bookings_page.dart';
import 'package:roombooker/views/pages/my_profile.dart';

 
class NavigationUtils {
  static void onItemTapped(
    BuildContext context,
    int index,
    int currentIndex,
  ) {
    if (index == currentIndex) return;
 
    Widget page;
 
    switch (index) {
      case 0:
        page = DashboardPage();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => page),
          (route) => false,
        );
        return;
 
      case 1:
        page = CreateBookingPage();
        break;
 
      case 2:
        page = AllBookings();
        break;

        case 3:
        page = MyBookingsPage();
        break;

        case 4:
        page = ProfilePage();
        break;
 
      default:
        return;
    }
 
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }
}