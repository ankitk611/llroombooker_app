import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:roombooker/core/constants/values.dart';
import 'package:roombooker/core/models/booking.dart';
import 'package:roombooker/widgets/bookingcard_mb.dart';  

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  final DateTime now = DateTime.now();

  // Sample booking data
  late final List<Booking> allBookings = [
    Booking(
      bookingId: "1",
      roomName: "Meeting Room 2",
      bookedBy: "Tanvi Lokhande",
      date: "${now.year}-${now.month}-${now.day}",
      startTime: "10:00",
      endTime: "11:00",
      status: "Confirmed",
    ),
    Booking(
      bookingId: "2",
      roomName: "Conference Room 1",
      bookedBy: "Amanullah Shaikh",
      date: "${now.year}-${now.month}-${now.day}",
      startTime: "15:00",
      endTime: "16:00",
      status: "Pending",
    ),
    // Add other bookings...
  ];

  // Filter out bookings where you are the organizer (bookedBy == "Your Name")
  List<Booking> get myUpcomingBookings {
    return allBookings.where((b) => b.bookedBy == "Tanvi Lokhande").toList();
  }

  // Reschedule booking method
  void _rescheduleBooking(Booking booking) async {
    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(booking.date),
      firstDate: DateTime(2022),
      lastDate: DateTime(2025),
    );

    if (newDate != null) {
      TimeOfDay? newTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.parse("${booking.date} ${booking.startTime}")),
      );

      if (newTime != null) {
        setState(() {
          // Update booking with new date and time
          booking.date = "${newDate.year}-${newDate.month}-${newDate.day}";
          booking.startTime = "${newTime.hour}:${newTime.minute}";
          booking.endTime = "${newTime.hour + 1}:${newTime.minute}"; // Keeping 1 hour duration as example
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Booking Rescheduled to ${booking.startTime}")),
        );
      }
    }
  }

  // Cancel booking method
  void _cancelBooking(Booking booking) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Cancel Booking"),
          content: Text("Are you sure you want to cancel this booking?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  allBookings.remove(booking);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Booking Canceled")),
                );
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
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
                  'My Bookings',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  FontAwesomeIcons.circlePlus,
                  size: 20,
                  color: Colors.blue.shade400,
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'View and manage your bookings',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _myBookingsList(),
          ],
        ),
      ),
    );
  }

  // Displays the list of bookings
  Widget _myBookingsList() {
    if (myUpcomingBookings.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          "No organizer bookings found.",
          style: AppText.secondary,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Upcoming Bookings",
          style: Styles.blueTitleTextStyle(fontSize: 26),
        ),
        const SizedBox(height: 12),
        ...myUpcomingBookings.map((b) => BookingCard(
          booking: b,
          onReschedule: () => _rescheduleBooking(b),
          onCancel: () => _cancelBooking(b),
        )),
      ],
    );
  }
}
