import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roombooker/core/constants/values.dart';
import 'package:roombooker/core/models/booking.dart';
import 'package:roombooker/widgets/bookingcard_widget.dart';
import 'package:roombooker/widgets/navbar_widget.dart';
import 'package:table_calendar/table_calendar.dart';

class AllBookings extends StatefulWidget {
  const AllBookings({super.key});

  @override
  State<AllBookings> createState() => _AllBookingsState();
}

class _AllBookingsState extends State<AllBookings> {
  final List<Booking> mockBookings = [
    Booking(
      bookingId: 'B001',
      roomName: 'Conference Room A',
      bookedBy: 'Ankit Kumar',
      date: '2026-01-16',
      startTime: '10:00',
      endTime: '11:00',
      status: 'Confirmed',
    ),
    Booking(
      bookingId: 'B002',
      roomName: 'Meeting Room B',
      bookedBy: 'Rahul',
      date: '2026-01-16',
      startTime: '14:00',
      endTime: '15:30',
      status: 'Confirmed',
    ),
    Booking(
      bookingId: 'B003',
      roomName: 'Conference Room A',
      bookedBy: 'Priya',
      date: '2026-01-17',
      startTime: '09:00',
      endTime: '10:00',
      status: 'Cancelled',
    ),
    Booking(
      bookingId: 'B002',
      roomName: 'Meeting Room B',
      bookedBy: 'Rahul',
      date: '2026-01-15',
      startTime: '14:00',
      endTime: '15:30',
      status: 'Confirmed',
    ),
  ];

  DateTime selectedDate = DateTime.now();
  List<Booking> bookings = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchBookingsForDate(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, // 👈 back button color
        ),
        elevation: 1,
        backgroundColor: const Color.fromARGB(255, 24, 0, 112),
        shadowColor: Colors.black.withOpacity(0.05),
        titleSpacing: 24,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'All Bookings',
                  style: Styles.whiteTitleTextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Icon(
                  FontAwesomeIcons.calendarDays,
                  size: 20,
                  color: Colors.blue.shade400,
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'View room reservations by date',
              style: Styles.whiteSubtitleTextStyle(fontSize: 12),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color.fromARGB(157, 100, 180, 246),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
                color: Colors.white,
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: selectedDate,
                selectedDayPredicate: (day) => isSameDay(day, selectedDate),

                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    selectedDate = selectedDay;
                  });
                  fetchBookingsForDate(selectedDay);
                },
                //Styles for header
                headerStyle: HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                  titleTextStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.blue),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: Colors.blue,
                  ),
                ),
                //Styles for days of week
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                  weekendStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.redAccent,
                  ),
                ),
                //Styles for individual days
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: const Color.fromARGB(255, 24, 146, 245),
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  weekendTextStyle: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.redAccent,
                  ),
                  outsideTextStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ),
          ),

          Divider(
            color: const Color.fromARGB(120, 115, 205, 247),
            thickness: 2,
          ),

          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : bookings.isEmpty
                ? Center(
                    child: Text(
                      "No bookings for this day",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return BookingCard(booking: booking);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavbar(currentIndex: 2),
    );
  }

  Future<void> fetchBookingsForDate(DateTime date) async {
    setState(() => isLoading = true);

    // Example API format: yyyy-MM-dd
    final formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    // TODO: Replace with API call
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      bookings = mockBookings.where((b) => b.date == formattedDate).toList();
      isLoading = false;
    });
  }
}
