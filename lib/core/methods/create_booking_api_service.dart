import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:roombooker/core/constants/url.dart';
import 'package:roombooker/core/methods/token_methods.dart';

import '../models/create_booking_models.dart';
import 'create_booking_service.dart';

class ApiCreateBookingService implements CreateBookingService {
  final _mock = MockCreateBookingService();

  @override
  Future<List<Room>> fetchRooms() {
    // ✅ Temporarily reuse mock rooms
    return _mock.fetchRooms();
  }

  @override
  Future<List<Attendee>> searchInternalAttendees(String query) async {
    final q = query.trim();
    if (q.length < 3) return []; // UI guard; API also enforces

    final token = await TokenUtils().getBearerToken();

    final uri = Uri.parse('${Url.baseUrl}/attendees/search-users')
    .replace(queryParameters: {"search": q});

    final res = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    final decoded = jsonDecode(res.body);

    // Supports: { data: [...] } OR [...]
    final List<dynamic> list = (decoded is Map<String, dynamic>)
        ? (decoded["data"] as List<dynamic>? ?? [])
        : (decoded as List<dynamic>? ?? []);

    return list
        .map((u) {
          final m = u as Map<String, dynamic>;

          return Attendee.internal(
            name: (m["name"] ?? m["display_name"] ?? "").toString(),
            email: (m["email"] ?? "").toString(),
          );
        })
        .where((a) => a.name.trim().isNotEmpty)
        .toList();
  }

  @override
  Future<void> submitBooking(CreateBookingRequest req) async {
    final token = await TokenUtils().getBearerToken();

    DateTime _combine(DateTime date, TimeOfDay tod) =>
        DateTime(date.year, date.month, date.day, tod.hour, tod.minute);

    String _formatDateTime(DateTime dt) {
      return dt.toIso8601String().replaceFirst('T', ' ').substring(0, 19);
    }

    DateTime startDt = _combine(req.date, req.startTime);
    DateTime endDt = _combine(req.date, req.endTime);

    // If end time is before/equals start time, treat as next day
    if (!endDt.isAfter(startDt)) {
      endDt = endDt.add(const Duration(days: 1));
    }

    final payload = <String, dynamic>{
      "title": req.meetingTitle,
      "description": req.description,
      "room_id": int.tryParse(req.roomId) ?? req.roomId,
      "start_time": _formatDateTime(startDt), // "YYYY-MM-DD HH:mm:ss"
      "end_time": _formatDateTime(endDt),
      "number_of_attendees": req.numberOfAttendees,

      "attendees": req.attendees.map((a) {
        // If your Attendee model doesn't have these fields yet,
        // the "??" defaults will keep API payload valid.
        return <String, dynamic>{"name": a.name, "email": a.email ?? ""};
      }).toList(),
    };

    final res = await http.post(
      Uri.parse('${Url.baseUrl}/bookings'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );
  }
}
