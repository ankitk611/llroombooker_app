import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/constants/create_booking_design.dart';

class DSCard extends StatelessWidget {
  const DSCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final Widget icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DS.l),
      decoration: BoxDecoration(
        color: DS.background,
        borderRadius: BorderRadius.circular(DS.cardRadius),
        border: Border.all(color: DS.border, width: 1),
        boxShadow: DS.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              icon,
              const SizedBox(width: DS.s),
              Expanded(
                child: Text(
                  title,
                  style: DS.text.cardTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: DS.l),
          child,
        ],
      ),
    );
  }
}

class TapField extends StatelessWidget {
  const TapField({
    super.key,
    required this.label,
    required this.value,
    required this.prefixIcon,
    required this.onTap,
  });

  final String label;
  final String value;
  final Widget prefixIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPlaceholder = value.trim().endsWith('...');

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: InputDecorator(
        decoration: DS.input(
          label: label,
          hint: '',
          prefixIcon: prefixIcon,
          suffixIcon: const Padding(
            padding: EdgeInsets.only(right: 10),
            child: FaIcon(
              FontAwesomeIcons.chevronDown,
              size: 14,
              color: DS.textSecondary,
            ),
          ),
        ),
        child: Text(
          value,
          style: DS.text.primary.copyWith(
            color: isPlaceholder ? DS.textSecondary : DS.textPrimary,
            fontWeight: isPlaceholder ? FontWeight.w400 : FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class CountPill extends StatelessWidget {
  const CountPill({super.key, required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DS.m, vertical: DS.xs),
      decoration: BoxDecoration(
        color: DS.primaryLight,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: DS.border),
      ),
      child: Text(
        count.toString(),
        style: DS.text.secondary.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}

class RemovableChip extends StatelessWidget {
  const RemovableChip({super.key, required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DS.m, vertical: DS.s),
      decoration: BoxDecoration(
        color: DS.primaryLight.withOpacity(0.75),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: DS.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              style: DS.text.secondary.copyWith(
                color: DS.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: DS.s),
          InkWell(
            onTap: onRemove,
            child: const FaIcon(
              FontAwesomeIcons.circleXmark,
              size: 16,
              color: DS.error,
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DS.l),
      decoration: BoxDecoration(
        color: DS.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DS.border, width: 1),
      ),
      child: Column(
        children: [
          const FaIcon(FontAwesomeIcons.users, size: 18, color: DS.textSecondary),
          const SizedBox(height: DS.s),
          Text(title, style: DS.text.primary.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: DS.xs),
          Text(subtitle, style: DS.text.secondary, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
