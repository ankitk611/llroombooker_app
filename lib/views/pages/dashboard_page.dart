import 'package:flutter/material.dart';
import 'package:roombooker/core/constants/values.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:roombooker/core/methods/token_methods.dart';
import 'package:roombooker/core/models/booking_db.dart';
import 'package:roombooker/views/pages/create_booking_page.dart';
import 'package:roombooker/views/pages/my_bookings_page.dart';
import 'package:roombooker/widgets/app_drawer.dart';
import 'package:roombooker/widgets/booking_card_db.dart';
import 'package:roombooker/widgets/navbar_widget.dart';
import 'package:roombooker/widgets/stat_item.dart';
import 'package:roombooker/widgets/appbar_widget.dart';
import 'package:roombooker/views/pages/my_profile.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:roombooker/core/constants/url.dart';

//---------FONTS----------
//---------Dashboard Page----------

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
  
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     throw UnimplementedError();
//   }
}

class _DashboardPageState extends State<DashboardPage> {
  static const Color mainBlue = Color(0xFF3B3870);

  //BookingFilter selectedFilter = BookingFilter.all;
  BookingFilter selectedFilter = BookingFilter.next10Days;

  final DateTime now = DateTime.now();

  List<BookingDb> allBookings = [];
  bool isLoadingBookings = false;

  //adding initState()
    @override
  void initState() {
    super.initState();
    fetchUpcomingBookings(); // ✅ ADD THIS LINE
  }



//adding model mapping function
BookingDb _mapApiBookingToBookingDb(Map<String, dynamic> json) {
  final start = DateTime.parse(json['start_time']).toLocal();
  final end = DateTime.parse(json['end_time']).toLocal();

  return BookingDb(
    id: json['id'],
    title: json['title'],
    room: json['room']['name'],
    organiser: json['user']['name'],
    attendees: json['number_of_attendees'] ?? 0,
    startTime: start,
    endTime: end,

    // Since API is unfiltered (testing)
    // we temporarily treat all as "mine"
    isMine: true,
    isAttendee: false,
  );
}


//adding fetch method
Future<void> fetchUpcomingBookings() async {
  setState(() => isLoadingBookings = true);

  try {
    final response = await http.get(
      Uri.parse('${Url.baseUrl}/bookings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await TokenUtils().getBearerToken()}',
      },
    );

    if (response.statusCode == 200) {
      //final List data = jsonDecode(response.body);
      final decoded = jsonDecode(response.body);

final List data = decoded is List
    ? decoded
    : decoded['data'] ?? [];


      final fetched = data
          .map((e) => _mapApiBookingToBookingDb(e))
          .toList();

      setState(() {
        allBookings = fetched;
      });
    } else {
      setState(() => allBookings = []);
    }
  } catch (e) {
    setState(() => allBookings = []);
  } finally {
    setState(() => isLoadingBookings = false);
  }
}


//----------Filtered Bookings List----------

 List<BookingDb> get upcomingBookings {
  final now = DateTime.now();
 

  List<BookingDb> filtered = allBookings
      .where((b) => b.startTime.isAfter(now))
      .toList();

//apply filter window

if (selectedFilter == BookingFilter.all) {
  final now = DateTime.now();
  return allBookings
      .where((b) => b.startTime.isAfter(now))
      .toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));
}


       if (selectedFilter == BookingFilter.today) {
    filtered = filtered.where((b) =>
        b.startTime.year == now.year &&
        b.startTime.month == now.month &&
        b.startTime.day == now.day
    ).toList();
  }

  if (selectedFilter == BookingFilter.next5Days) {
    // filtered = filtered.where((b) =>
    //     b.startTime.isAfter(now.subtract(const Duration(days: 5)))
    // ).toList();
    final limit = now.add(const Duration(days: 5));
    filtered = filtered.where((b) => b.startTime.isBefore(limit)).toList();
  }

  if (selectedFilter == BookingFilter.next10Days) {
    // filtered = filtered.where((b) =>
    //     b.startTime.isAfter(now.subtract(const Duration(days: 10)))
    // ).toList();
    final limit = now.add(const Duration(days: 10));
    filtered = filtered.where((b) => b.startTime.isBefore(limit)).toList();
  }

  filtered.sort((a, b) => a.startTime.compareTo(b.startTime));
  return filtered;
}

  // filtered.sort((a, b) => b.startTime.compareTo(a.startTime));
  // return filtered.take(5).toList();




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appName: 'RoomBooker', // Set the app name here
        onNotificationsPressed: () async{
          // Handle notifications
          final String? token = await TokenUtils().getBearerToken();
          print('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
          print(token);
        },
        onProfilePressed: () {
          // Handle profile
         Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage(),
         ),
         );
        },
      ),
      drawer: const AppDrawer(currentIndex: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dashboardHeader(),
            const SizedBox(height: 16),
            _quickActions(),
            const SizedBox(height: 24),
            _statusBar(),
            const SizedBox(height: 32),
            _upcomingBookings(),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavbar(currentIndex: 0),
    );
  }

  Widget _dashboardHeader() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Dashboard",
            style: Styles.blueTitleTextStyle(fontSize: 28),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  // Handle notification button press
                },
              ),
              IconButton(
              onPressed: _showFilterSheet, // ✅ BEST & CLEANEST
              icon: const Icon(Icons.filter_list),
            ),
  
            ],
          ),
        ],
      );
  
  }

  //----------quick actions widget----------
  Widget _quickActions() {
    return Row(
      children: [
        _actionButton(Icons.add, "New Booking",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>  CreateBookingPage(),
            ),
          );
        },),
        const SizedBox(width: 12),
        _actionButton(Icons.check, "My Bookings", 
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MyBookingsPage(),
            ),
          );
        },),
      ],
    );
  }

Widget _actionButton(
  IconData icon,
  String label, {
  required VoidCallback onPressed,
}) {
  return Expanded(
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 16,
          color: AppColors.primary,
        ),
        label: Text(
          label,
          style: AppText.primary.copyWith(
            fontWeight: FontWeight.w600, // 🔹 stronger CTA
            letterSpacing: 0.2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ),
  );
}


//----------status bar widget----------
  Widget _statusBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        StatItem(FontAwesomeIcons.building, "22", "Total\nRooms"),
        StatItem(FontAwesomeIcons.calendarCheck, "2274", "Total\nBookings"),
        StatItem(FontAwesomeIcons.clock, upcomingBookings.length.toString(), "My Upcoming\nBookings",),
        StatItem(FontAwesomeIcons.calendarDay, "12", "Today's\nBookings"),
      ],
    );
  }

  //----------upcoming bookings widget----------

    Widget _upcomingBookings() {
      if (isLoadingBookings) {
    return const Center(child: CircularProgressIndicator());
  }

  if (upcomingBookings.isEmpty) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Upcoming Meetings",
          style: Styles.blueTitleTextStyle(fontSize: 26),
        ),
        const SizedBox(height: 12),
        const Text(
          "No upcoming meetings",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          "Upcoming Meetings",
          style: Styles.blueTitleTextStyle(fontSize: 26),
        ),
        const SizedBox(height: 12),
        ...upcomingBookings.map((b) => BookingCard(booking: b)),
      ],
    );
  }

  // ------------------ FILTER SHEET ------------------
 void _showFilterSheet() {
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: AppColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              "Filter Meetings",
              style: AppText.cardTitle,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                
                _styledRadio("Today", BookingFilter.today, setModalState),
                _styledRadio("Next 5 Days", BookingFilter.next5Days, setModalState),
                _styledRadio("Next 10 Days", BookingFilter.next10Days, setModalState),

              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel", style: AppText.secondary),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Apply",
                  style: AppText.primary.copyWith(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}



Widget _styledRadio(
  String label,
  BookingFilter value,
  void Function(void Function()) setModalState,
) {
  return RadioListTile<BookingFilter>(
    title: Text(label, style: AppText.secondary),
    value: value,
    // ignore: deprecated_member_use
    groupValue: selectedFilter,
    activeColor: AppColors.primary,
    // ignore: deprecated_member_use
    onChanged: (BookingFilter? newValue) {
      setModalState(() {
        selectedFilter = newValue!;
      });
      setState(() {}); // updates dashboard bookings
    },
  );
}



    Widget _filterTile(String label, BookingFilter filter) {
    return ListTile(
      title: Text(label),
      onTap: () {
        setState(() => selectedFilter = filter);
        Navigator.pop(context);
      },
    );
  }
}
