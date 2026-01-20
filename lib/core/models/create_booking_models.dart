import 'package:flutter/material.dart';

class Room {
  final String id;
  final String name;
  final int capacity;

  const Room({required this.id, required this.name, required this.capacity});
}

enum AttendeeType { internal, external }

class Attendee {
  final AttendeeType type;
  final String name;
  final String? email;

  const Attendee._({required this.type, required this.name, required this.email});

  const Attendee.internal({required String name, required String email})
      : this._(type: AttendeeType.internal, name: name, email: email);

  const Attendee.external({required String name, String? email})
      : this._(type: AttendeeType.external, name: name, email: email);

  String get displayLabel {
    final e = (email ?? '').trim();
    return e.isEmpty ? name : '$name ($e)';
  }
}

class CreateBookingRequest {
  final String meetingTitle;
  final String roomId;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isRecurring;
  final int numberOfAttendees;
  final List<Attendee> attendees;
  final String description;

  const CreateBookingRequest({
    required this.meetingTitle,
    required this.roomId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isRecurring,
    required this.numberOfAttendees,
    required this.attendees,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    String hhmm(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    return {
      'meetingTitle': meetingTitle,
      'roomId': roomId,
      'date': date.toIso8601String(),
      'startTime': hhmm(startTime),
      'endTime': hhmm(endTime),
      'isRecurring': isRecurring,
      'numberOfAttendees': numberOfAttendees,
      'attendees': attendees
          .map((a) => {'type': a.type.name, 'name': a.name, 'email': a.email})
          .toList(),
      'description': description,
    };
  }
}
