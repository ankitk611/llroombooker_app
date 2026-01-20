import 'package:flutter/material.dart';
import 'package:roombooker/core/constants/values.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:roombooker/core/models/booking_db.dart';
import 'package:roombooker/widgets/booking_card_db.dart';
import 'package:roombooker/widgets/stat_item.dart';
import 'package:roombooker/views/pages/add_booking_page.dart';


//---------FONTS----------
//---------Dashboard Page----------

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class _DashboardPageState extends State<DashboardPage> {
  static const Color mainBlue = Color(0xFF3B3870);

  //BookingFilter selectedFilter = BookingFilter.all;
  BookingFilter selectedFilter = BookingFilter.all;

  final DateTime now = DateTime.now();

late final List<BookingDb> allBookings = [
  // TODAY (2 bookings)
  BookingDb(
    title: "Leadership Vendor Meet Up",
    room: "Meeting Room 2",
    organiser: "Tanvi Lokhande",
    attendees: 3,
    startTime: DateTime(now.year, now.month, now.day, 10, 0),
    endTime: DateTime(now.year, now.month, now.day, 11, 0),
    isMine: true,
  ),
  BookingDb(
    title: "Product Sync",
    room: "Conference Room 1",
    organiser: "Amanullah Shaikh",
    attendees: 5,
    startTime: DateTime(now.year, now.month, now.day, 15, 0),
    endTime: DateTime(now.year, now.month, now.day, 16, 0),
    isAttendee: true,
  ),

  // LAST 5 DAYS (2 more)
  BookingDb(
    title: "Design Review",
    room: "Meeting Room 3",
    organiser: "Tanvi Lokhande",
    attendees: 4,
    startTime: now.subtract(const Duration(days: 3)),
    endTime: now.subtract(const Duration(days: 3)).add(const Duration(hours: 1)),
    isMine: true,
  ),
  BookingDb(
    title: "Tech Catch-up",
    room: "Conference Room 2",
    organiser: "Amanullah Shaikh",
    attendees: 2,
    startTime: now.subtract(const Duration(days: 5)),
    endTime: now.subtract(const Duration(days: 5)).add(const Duration(hours: 1)),
    isAttendee: true,
  ),

  // LAST 10 DAYS (1 more)
  BookingDb(
    title: "Monthly Planning",
    room: "Board Room",
    organiser: "Leadership Team",
    attendees: 8,
    startTime: now.subtract(const Duration(days: 9)),
    endTime: now.subtract(const Duration(days: 9)).add(const Duration(hours: 2)),
    isMine: true,
  ),
];

//----------Filtered Bookings List----------

 List<BookingDb> get upcomingBookings {
  List<BookingDb> filtered =
      allBookings.where((b) => b.isMine || b.isAttendee).toList();

  final now = DateTime.now();

  if (selectedFilter == BookingFilter.today) {
    filtered = filtered.where((b) =>
      b.startTime.year == now.year &&
      b.startTime.month == now.month &&
      b.startTime.day == now.day
    ).toList();
  }

  if (selectedFilter == BookingFilter.tomorrow) {
    filtered = filtered.where((b) =>
      b.startTime.isAfter(now.subtract(const Duration(days: 5)))
    ).toList();
  }

  if (selectedFilter == BookingFilter.custom) {
    filtered = filtered.where((b) =>
      b.startTime.isAfter(now.subtract(const Duration(days: 10)))
    ).toList();
  }

  filtered.sort((a, b) => b.startTime.compareTo(a.startTime));
  return filtered.take(5).toList();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
    backgroundColor: AppColors.textPrimary,
    elevation: 0,
    title: Text(
      "Dashboard",
      style: AppText.screenTitle.copyWith(color: Colors.white),
    ),
      ),
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
              builder: (context) => const CreateBookingPage(),
            ),
          );
        },),
        const SizedBox(width: 12),
        _actionButton(Icons.check, "My Bookings", onPressed: () {  }),
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
        StatItem(FontAwesomeIcons.clock, "0", "Pending\nApprovals"),
        StatItem(FontAwesomeIcons.calendarDay, "12", "Today's\nBookings"),
      ],
    );
  }

  //----------upcoming bookings widget----------

    Widget _upcomingBookings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          "Upcoming Bookings",
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
            _styledRadio("Today", BookingFilter.today),
            _styledRadio("Last 5 Days", BookingFilter.tomorrow),
            _styledRadio("Last 10 Days", BookingFilter.custom),
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
}


Widget _styledRadio(String label, BookingFilter value) {
  return RadioListTile<BookingFilter>(
    title: Text(label, style: AppText.secondary),
    value: value,
    groupValue: selectedFilter,
    activeColor: AppColors.primary,
    onChanged: (BookingFilter? newValue) {
      setState(() {
        selectedFilter = newValue!;
      });
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
