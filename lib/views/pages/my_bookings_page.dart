import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:roombooker/core/constants/values.dart';
//import 'package:roombooker/core/models/booking.dart';
//import 'package:roombooker/widgets/bookingcard_mb.dart';
//new imports
import 'package:roombooker/core/constants/url.dart';
import 'package:roombooker/core/methods/token_methods.dart';
import 'package:roombooker/core/models/booking_db.dart';
import 'package:roombooker/widgets/booking_card_db.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  final DateTime now = DateTime.now();

  //Call API on page load:
  @override
void initState() {
  super.initState();
  fetchMyBookings(); // 👈 THIS was missing
}

  // Sample booking data
  // List<Map<String, dynamic>> allBookings = [];
  //   bool isLoading = false;
  List<BookingDb> allBookings = [];
  bool isLoading = false;

  BookingDb _mapApiToBookingDb(Map<String, dynamic> json) {
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
    isMine: true,      // 👈 this is MY bookings
    isAttendee: false,
  );
}



  // Filter out bookings where you are the organizer (bookedBy == "Your Name")
 List<BookingDb> get myUpcomingBookings => allBookings;
//  {
//   final now = DateTime.now();
//   return allBookings
//       .where((b) => b.startTime.isAfter(now))
//       .toList()
//     ..sort((a, b) => a.startTime.compareTo(b.startTime));
// }


//---fetch API without mapping to model----
Future<void> fetchMyBookings() async {
  setState(() => isLoading = true);

  try {
    final token = await TokenUtils().getBearerToken();

    final response = await http.get(
      Uri.parse('${Url.baseUrl}/bookings/mybookings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List data = decoded is List ? decoded : decoded['data'] ?? [];

      final fetched = data
          .map((e) => _mapApiToBookingDb(e))
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
    setState(() => isLoading = false);
  }
}



  // // Reschedule booking method
   Future<void> _openReschedulePicker(BookingDb booking) async {
    final now = DateTime.now();
    // ✅ Ensure initialDate is valid
  final initialDate = booking.startTime.isBefore(now)
      ? now
      : booking.startTime;

  final newDate = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: now,
    lastDate: now.add(const Duration(days: 365)),
  );

  if (newDate == null) return;

  // ⏰ CLOCK UI (this is what you wanted)
  final newStartTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(booking.startTime),
  );

  if (newStartTime == null) return;

  final newStart = DateTime(
    newDate.year,
    newDate.month,
    newDate.day,
    newStartTime.hour,
    newStartTime.minute,
  );

  final newEnd = newStart.add(const Duration(hours: 1));

  await rescheduleBooking(
    bookingId: booking.id,
    newStart: newStart,
    newEnd: newEnd,
  );
  }

  // // Cancel booking method
  // void _cancelBooking(Booking booking) {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text("Cancel Booking"),
  //         content: Text("Are you sure you want to cancel this booking?"),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: Text("No"),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               setState(() {
  //                 allBookings.remove(booking);
  //               });
  //               Navigator.of(context).pop();
  //               ScaffoldMessenger.of(
  //                 context,
  //               ).showSnackBar(SnackBar(content: Text("Booking Canceled")));
  //             },
  //             child: Text("Yes"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  //Update Booking
  Future<void> rescheduleBooking({
  required int bookingId,
  required DateTime newStart,
  required DateTime newEnd,
}) async {
  try {
    final token = await TokenUtils().getBearerToken();

    final response = await http.put(
      Uri.parse('${Url.baseUrl}/bookings/$bookingId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "start_time": newStart.toIso8601String(),
        "end_time": newEnd.toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      fetchMyBookings(); // 👈 refresh list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking rescheduled')),
      );
    } else {
      throw Exception('Reschedule failed');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to reschedule booking')),
    );
  }
}


  Future<void> deleteBooking(int bookingId) async {
  try {
    final token = await TokenUtils().getBearerToken();

    final response = await http.delete(
      Uri.parse('${Url.baseUrl}/bookings/$bookingId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        allBookings.removeWhere((b) => b.id == bookingId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking cancelled')),
      );
    } else {
      throw Exception('Delete failed');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to cancel booking')),
    );
  }
}

//confirm dialog
void confirmDelete(BookingDb booking) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Cancel booking'),
      content: const Text('Are you sure you want to cancel this booking?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            deleteBooking(booking.id);
          },
          child: const Text('Yes'),
        ),
      ],
    ),
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
          children: [_myBookingsList()],
        ),
      ),
    );
  }

  // Displays the list of bookings
  Widget _myBookingsList() {
  if (isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  if (myUpcomingBookings.isEmpty) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Text("No bookings found.", style: AppText.secondary),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "My Bookings",
        style: Styles.blueTitleTextStyle(fontSize: 26),
      ),
      const SizedBox(height: 12),
      ...myUpcomingBookings.map(
        (b) => BookingCard( booking: b,
  onReschedule: () => _openReschedulePicker(b),
  onCancel: () => confirmDelete(b),
  ),
      ),
    ],
  );
}

}
