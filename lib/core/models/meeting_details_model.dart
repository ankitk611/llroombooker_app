
enum BookingFilter { today, last5Days, last10Days, all, next5Days, next10Days }

class MeetingDetails {
  final int id;
  final String title;
  final String room;
  final String organiser;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> attendeeNames;

  final bool isMine;
  final bool isAttendee;
  
  MeetingDetails({
    required this.id,
    required this.title,
    required this.room,
    required this.organiser,
    required this.startTime,
    required this.endTime,
    required this.attendeeNames,

     
    this.isMine = false,
    this.isAttendee = false,
  });
}