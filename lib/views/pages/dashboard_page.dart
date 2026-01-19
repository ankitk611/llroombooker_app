import 'package:flutter/material.dart';
import 'package:roombooker/core/constants/values.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


//----------Colors----------
class AppColors {
  static const primary = Color(0xFF1892F5);
  static const primaryLight = Color(0xFFE8F2FE);
  static const border = Color(0xFFDCE6F1);

  static const textPrimary = Color(0xFF1F2937);
  static const textSecondary = Color(0xFF6B7280);

  static const success = Color(0xFF22C55E);
  static const error = Color(0xFFEF4444);

  static const background = Colors.white;
}

//---------FONTS----------
class AppText {
  static TextStyle screenTitle = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle cardTitle = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle primary = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle secondary = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle label = GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
}



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

late final List<Booking> allBookings = [
  // TODAY (2 bookings)
  Booking(
    title: "Leadership Vendor Meet Up",
    room: "Meeting Room 2",
    organiser: "Tanvi Lokhande",
    attendees: 3,
    startTime: DateTime(now.year, now.month, now.day, 10, 0),
    endTime: DateTime(now.year, now.month, now.day, 11, 0),
    isMine: true,
  ),
  Booking(
    title: "Product Sync",
    room: "Conference Room 1",
    organiser: "Amanullah Shaikh",
    attendees: 5,
    startTime: DateTime(now.year, now.month, now.day, 15, 0),
    endTime: DateTime(now.year, now.month, now.day, 16, 0),
    isAttendee: true,
  ),

  // LAST 5 DAYS (2 more)
  Booking(
    title: "Design Review",
    room: "Meeting Room 3",
    organiser: "Tanvi Lokhande",
    attendees: 4,
    startTime: now.subtract(const Duration(days: 3)),
    endTime: now.subtract(const Duration(days: 3)).add(const Duration(hours: 1)),
    isMine: true,
  ),
  Booking(
    title: "Tech Catch-up",
    room: "Conference Room 2",
    organiser: "Amanullah Shaikh",
    attendees: 2,
    startTime: now.subtract(const Duration(days: 5)),
    endTime: now.subtract(const Duration(days: 5)).add(const Duration(hours: 1)),
    isAttendee: true,
  ),

  // LAST 10 DAYS (1 more)
  Booking(
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
 List<Booking> get upcomingBookings {
  List<Booking> filtered =
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

//   AppBar _buildAppBar() {
//   return AppBar(
//     backgroundColor: AppColors.primary,
//     elevation: 0,

//     title: Image.asset(
//       'assets/images/roombooker_logo.png',
//       height: 38, // logo now has presence
//       fit: BoxFit.contain,
//     ),

//     actions: [
//       IconButton(
//         icon: const FaIcon(
//           FontAwesomeIcons.bell,
//           size: 16,
//           color: Colors.white,
//         ),
//         onPressed: () {},
//       ),
//       IconButton(
//         onPressed: () {},
//         icon: Container(
//           padding: const EdgeInsets.all(6),
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             border: Border.all(color: Colors.white, width: 1),
//           ),
//           child: const FaIcon(
//             FontAwesomeIcons.user,
//             size: 14,
//             color: Colors.white,
//           ),
//         ),
//       ),
//       const SizedBox(width: 8),
//     ],
//   );
// }

    
      
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
        _actionButton(Icons.add, "New Booking"),
        const SizedBox(width: 12),
        _actionButton(Icons.check, "My Bookings"),
      ],
    );
  }

Widget _actionButton(IconData icon, String label) {
  return Expanded(
    child: ElevatedButton.icon(
      onPressed: () {
        // Handle action button press
      },
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: AppText.primary,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight, // same for both
        foregroundColor: AppColors.textPrimary,
        elevation: 0, // clean, flat enterprise look
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}




  //----------status bar widget----------
  Widget _statusBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        _StatItem(FontAwesomeIcons.building, "22", "Total\nRooms"),
        _StatItem(FontAwesomeIcons.calendarCheck, "2274", "Total\nBookings"),
        _StatItem(FontAwesomeIcons.clock, "0", "Pending\nApprovals"),
        _StatItem(FontAwesomeIcons.calendarDay, "12", "Today's\nBookings"),
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

class BookingCard extends StatelessWidget {
  final Booking booking;

  const BookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            booking.title,
            style: AppText.cardTitle,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            "${booking.room} • ${booking.organiser}",
            style: AppText.secondary,
          ),
          const SizedBox(height: 4),
          Text(
            "${booking.attendees} people • "
            "${booking.startTime.hour}:${booking.startTime.minute.toString().padLeft(2, '0')} - "
            "${booking.endTime.hour}:${booking.endTime.minute.toString().padLeft(2, '0')}",
            style: AppText.label,
          ),
        ],
      ),
    );
  }
}


class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem(this.icon, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white,
          child: Icon(icon, color: Colors.black),
        ),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}


enum BookingFilter { today, tomorrow, custom, all }


class Booking {
  final String title;
  final String room;
  final String organiser;
  final DateTime startTime;
  final DateTime endTime;
  final int attendees;
  final bool isMine;
  final bool isAttendee;

  Booking({
    required this.title,
    required this.room,
    required this.organiser,
    required this.startTime,
    required this.endTime,
    required this.attendees,
    this.isMine = false,
    this.isAttendee = false,
  });
}