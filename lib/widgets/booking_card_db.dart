import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:roombooker/core/constants/values.dart';
import 'package:roombooker/core/models/booking_db.dart';

class BookingCard extends StatefulWidget {
  final BookingDb booking;
  final VoidCallback onReschedule;
  final VoidCallback onCancel;

  const BookingCard({
    super.key,
    required this.booking,
    required this.onReschedule,
    required this.onCancel,
  });

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() => _expanded = !_expanded);
        },
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),

                if (_expanded) ...[
                  const Divider(height: 24),

                  _details(),

                  const SizedBox(height: 12),
                  _attendees(),

                  const SizedBox(height: 16),
                  _actions(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.booking.title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(widget.booking.room,
                style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
      Icon(
        _expanded ? Icons.expand_less : Icons.expand_more,
        color: Colors.grey,
      ),
    ],
  );
}

Widget _details() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("Organiser: ${widget.booking.organiser}"),
      const SizedBox(height: 4),
      Text(
        "Time: ${widget.booking.startTime} - ${widget.booking.endTime}",
      ),
    ],
  );
}

Widget _attendees() {
  if (widget.booking.attendeeNames.isEmpty) {
    return const Text(
      "No attendees",
      style: TextStyle(color: Colors.grey),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Attendees",
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      ...widget.booking.attendeeNames.map(
        (name) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              const Icon(Icons.person, size: 16),
              const SizedBox(width: 6),
              Text(name),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget _actions() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      TextButton(
        onPressed: widget.onReschedule,
        child: const Text("Reschedule"),
      ),
      const SizedBox(width: 8),
      TextButton(
        onPressed: widget.onCancel,
        style: TextButton.styleFrom(foregroundColor: Colors.red),
        child: const Text("Cancel"),
      ),
    ],
  );
}

    }
