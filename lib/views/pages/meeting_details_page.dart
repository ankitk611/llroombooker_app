import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:roombooker/core/constants/values.dart';
import 'package:roombooker/core/models/booking_db.dart';
import 'package:roombooker/core/models/meeting_details_model.dart';
import 'package:roombooker/core/constants/url.dart';
import 'package:roombooker/core/methods/token_methods.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MeetingDetailsPage extends StatefulWidget {
  final BookingDb booking;

  const MeetingDetailsPage({
    super.key,
    required this.booking,
  });

  @override
  State<MeetingDetailsPage> createState() => _MeetingDetailsPageState();
}

class _MeetingDetailsPageState extends State<MeetingDetailsPage> {
 late Future<MeetingDetails> meetingFuture;

 @override
 void initState() {
  super.initState();
  meetingFuture = fetchMeetingDetails(widget.booking.id);
 }

 Future<MeetingDetails> fetchMeetingDetails(int meetingId) async {
  final token = await TokenUtils().getBearerToken();

  //final url = Uri.parse('${Url.baseUrl}/meetings/$meetingId');

  final response = await http.get(
    Uri.parse('${Url.baseUrl}/bookings/mybookings'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

 if (response.statusCode != 200) {
      throw Exception('Failed to load meeting details');
    }

        final json = jsonDecode(response.body);

    return MeetingDetails(
      id: json['id'],
      title: json['title'],
      room: json['room']['name'],
      organiser: json['user']['name'],
      startTime: DateTime.parse(json['start_time']).toLocal(),
      endTime: DateTime.parse(json['end_time']).toLocal(),
      attendeeNames: (json['attendees'] as List? ?? [])
          .map((a) => a['name'].toString())
          .toList(),
      isMine: true,
    );
}

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meeting Details")),
      body: FutureBuilder<MeetingDetails>(
        future: meetingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Failed to load meeting details"));
          }

          final meeting = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(meeting),
                const SizedBox(height: 16),
                _time(meeting),
                const SizedBox(height: 16),
                _organiser(meeting),
                const SizedBox(height: 24),
                _attendees(meeting),
                const SizedBox(height: 32),
                _actions(context, meeting),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _header(MeetingDetails meeting) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        meeting.title,
        style: AppText.cardTitle.copyWith(fontSize: 22),
      ),
      const SizedBox(height: 4),
      Text(
        meeting.room,
        style: AppText.secondary,
      ),
    ],
  );
}

Widget _time(MeetingDetails meeting) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        const FaIcon(
          FontAwesomeIcons.clock,
          size: 14,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          "${_formatTime(meeting.startTime)} - ${_formatTime(meeting.endTime)}",
          style: AppText.primary,
        ),
      ],
    ),
  );
}

Widget _organiser(MeetingDetails meeting) {
  return Row(
    children: [
      const FaIcon(
        FontAwesomeIcons.userTie,
        size: 14,
        color: AppColors.primary,
      ),
      const SizedBox(width: 8),
      Text(
        meeting.organiser,
        style: AppText.primary,
      ),
    ],
  );
}

Widget _attendees(MeetingDetails meeting) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Attendees",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 12),

      if (meeting.attendeeNames.isEmpty)
        const Text("No attendees"),

      ...meeting.attendeeNames.map(
        (name) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.person),
          title: Text(name),
        ),
      ),
    ],
  );
}

Widget _actions(BuildContext context, MeetingDetails meeting) {
  if (!meeting.isMine) return const SizedBox();

  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      TextButton.icon(
        onPressed: () {
          // call reschedule from parent or service
        },
        icon: const Icon(Icons.edit),
        label: const Text("Reschedule"),
      ),
      const SizedBox(width: 8),
      TextButton.icon(
        onPressed: () {
          // confirm + cancel
        },
        icon: const Icon(Icons.delete, color: Colors.red),
        label: const Text(
          "Cancel",
          style: TextStyle(color: Colors.red),
        ),
      ),
    ],
  );
}
String _formatTime(DateTime t) {
  return "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
}
}
