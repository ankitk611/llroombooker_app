import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:roombooker/core/constants/values.dart';

class StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const StatItem(
    this.icon,
    this.value,
    this.label, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Icon container (outlined + shadow)
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: FaIcon(
              icon,
              size: 16,
              color: AppColors.primary,
            ),
          ),
        ),

        const SizedBox(height: 8),

        /// Value (dominant)
        Text(
          value,
          style: AppText.primary.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 2),

        /// Label (subtle)
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppText.label,
        ),
      ],
    );
  }
}
