import 'dart:convert';
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

  Future<List<Attendee>> fetchAllInternalAttendees() async {
  final token = await TokenUtils().getBearerToken();

  final res = await http.get(
    Uri.parse('${Url.baseUrl}/users'),
    headers: {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    },
  );

  final decoded = jsonDecode(res.body);

  // supports: { data: [...] } OR [...]
  final List<dynamic> list = (decoded is Map<String, dynamic>)
      ? (decoded["data"] as List<dynamic>? ?? [])
      : (decoded as List<dynamic>? ?? []);

  return list.map((u) {
    final m = u as Map<String, dynamic>;

    final name = (m["name"] ?? m["full_name"] ?? m["display_name"] ?? "").toString();
    final email = (m["email"] ?? m["mail"] ?? "").toString();

    return Attendee.internal(
      name: name.isEmpty ? "Unknown" : name,
      email: email,
    );
  }).where((a) => a.name.trim().isNotEmpty).toList();
}



  @override
  Future<void> submitBooking(CreateBookingRequest req) async {
    // implement later
  }
  
  @override
  Future<List<Attendee>> searchInternalAttendees(String query) {
    // TODO: implement searchInternalAttendees
    throw UnimplementedError();
  }
}

