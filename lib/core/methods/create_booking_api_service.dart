import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/create_booking_models.dart';
import 'create_booking_service.dart';

class ApiCreateBookingService implements CreateBookingService {
  static const String _baseUrl =
      'http://172.16.2.75/meetingroom/api';

  final _mock = MockCreateBookingService();

  @override
  Future<List<Room>> fetchRooms() {
    // ✅ Temporarily reuse mock rooms
    return _mock.fetchRooms();
  }

  @override
  @override
Future<List<Attendee>> searchInternalAttendees(String query) async {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return [];

  final response = await http.get(
    Uri.parse('$_baseUrl/users'),
    headers: {
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to load users');
  }

  final Map<String, dynamic> json =
      jsonDecode(response.body) as Map<String, dynamic>;

  final List<dynamic> users = json['data'] as List<dynamic>;

  return users
      .where((u) {
        final name = (u['name'] ?? '').toString().toLowerCase();
        final email = (u['email'] ?? '').toString().toLowerCase();
        return name.contains(q) || email.contains(q);
      })
      .map(
        (u) => Attendee.internal(
          name: u['name'] as String,
          email: u['email'] as String,
        ),
      )
      .take(8)
      .toList();
}


  @override
  Future<void> submitBooking(CreateBookingRequest req) async {
    // implement later
  }
}

