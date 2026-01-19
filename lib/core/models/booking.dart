class Booking {
  final String bookingId;
  final String roomName;
  final String bookedBy;
  final String date;
  final String startTime;
  final String endTime;
  final String status;

  Booking({
    required this.bookingId,
    required this.roomName,
    required this.bookedBy,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
  });
}