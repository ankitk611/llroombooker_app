import '../models/create_booking_models.dart';

abstract class CreateBookingService {
  Future<List<Room>> fetchRooms();
  Future<List<Attendee>> searchInternalAttendees(String query);
  Future<void> submitBooking(CreateBookingRequest req);
}

/// Mock service (replace with real API implementation later)
class MockCreateBookingService implements CreateBookingService {
  const MockCreateBookingService();

  @override
  Future<List<Room>> fetchRooms() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const [
      Room(id: 'R1', name: 'Conference Room - 1', capacity: 8),
      Room(id: 'R2', name: 'Conference Room - 2', capacity: 12),
      Room(id: 'R3', name: 'Board Room', capacity: 20),
      Room(id: 'R4', name: 'Huddle Space', capacity: 4),
    ];
  }

  @override
  Future<List<Attendee>> searchInternalAttendees(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    const directory = [
      Attendee.internal(name: 'Aayushman Gupta', email: 'aayushman@company.com'),
      Attendee.internal(name: 'Manoj Bilapati', email: 'manoj@company.com'),
      Attendee.internal(name: 'Kavita Sharma', email: 'kavita@company.com'),
      Attendee.internal(name: 'Rohan Patil', email: 'rohan@company.com'),
      Attendee.internal(name: 'Pranav Mehta', email: 'pranav@company.com'),
      Attendee.internal(name: 'Mukta Patel', email: 'mukta@company.com'),
    ];

    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return directory
        .where((a) =>
            a.name.toLowerCase().contains(q) ||
            (a.email ?? '').toLowerCase().contains(q))
        .take(8)
        .toList(growable: false);
  }

  @override
  Future<void> submitBooking(CreateBookingRequest req) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }
}
