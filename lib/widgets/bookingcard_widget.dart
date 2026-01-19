import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({super.key, required this.booking});

  final booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.shade100,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Meeting Title
          Text(
            'Internal Audit',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 4),

          /// Room Name
          Text(
            'Meeting Room - 3',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey,
            ),
          ),

          const SizedBox(height: 12),

          /// Organizer & Attendees
          Row(
            children: [
              /// Organizer
              Expanded(
                child: Row(
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.userTie,
                      size: 14,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Dviti Shah',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.black87,
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
                    size: 14,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '3 people',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// Time Row
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.clock,
                  size: 14,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  '10:00 AM - 8:00 PM',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
