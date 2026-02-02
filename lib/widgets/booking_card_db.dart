import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
 
import 'package:roombooker/core/constants/values.dart';
import 'package:roombooker/core/models/booking_db.dart';

import 'package:roombooker/views/pages/meeting_details_page.dart';
 
class BookingCard extends StatelessWidget {
  final BookingDb booking;
  final VoidCallback? onReschedule;
  final VoidCallback? onCancel;
 
  const BookingCard({
    super.key,
    required this.booking,
     this.onReschedule,
    this.onCancel,
  });
 
  @override
  Widget build(BuildContext context) {
     return InkWell(
  borderRadius: BorderRadius.circular(16),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MeetingDetailsPage(booking: booking),
      ),
    );
  },
    child: Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 Meeting Title
          Text(
            booking.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.cardTitle,
          ),
 
          const SizedBox(height: 4),
 
          /// 🔹 Room Name
          Text(
            booking.room,
            style: AppText.secondary,
          ),
 
          const SizedBox(height: 12),
 
          /// 🔹 Organizer & Attendees
          Row(
            children: [
              /// Organizer
              Expanded(
                child: Row(
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.userTie,
                      size: 13,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        booking.organiser,
                        style: AppText.primary,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
 
              /// Attendees
              Row(
                children: [
                  const FaIcon(
                    FontAwesomeIcons.users,
                    size: 13,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "${booking.attendees} people",
                    style: AppText.primary,
                  ),
                ],
              ),
            ],
          ),
 
          const SizedBox(height: 12),
 
          /// 🔹 Time Row
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.clock,
                  size: 13,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTimeRange(),
                  style: AppText.primary,
                ),
              ],
            ),
          ),
          if (booking.isMine)
  Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      TextButton.icon(
        onPressed: onReschedule,
        icon: const Icon(Icons.edit, size: 18),
        label: const Text('Reschedule'),
      ),
      const SizedBox(width: 8),
      TextButton.icon(
        onPressed: onCancel,
        icon: const Icon(Icons.delete, size: 18, color: Colors.red),
        label: const Text(
          'Cancel',
          style: TextStyle(color: Colors.red),
        ),
      ),
    ],
  ),
 
        ],
      ),
    ),
     );
   
  }
 
  String _formatTimeRange() {
    String start =
        "${booking.startTime.hour.toString().padLeft(2, '0')}:${booking.startTime.minute.toString().padLeft(2, '0')}";
    String end =
        "${booking.endTime.hour.toString().padLeft(2, '0')}:${booking.endTime.minute.toString().padLeft(2, '0')}";
    return "$start – $end";
  }
}