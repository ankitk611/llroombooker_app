import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DS {
  // Colors
  static const Color primary = Color(0xFF1892F5);
  static const Color primaryLight = Color(0xFFE8F2FE);
  static const Color border = Color(0xFFDCE6F1);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color background = Color(0xFFFFFFFF);

  // Spacing
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;

  // Card
  static const double cardRadius = 16;
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.08),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  // Typography
  static const DSText text = DSText();

  // Input
  static InputDecoration input({
    required String label,
    required String hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: DS.text.label,
      hintStyle: DS.text.label.copyWith(color: DS.textSecondary),
      prefixIcon: prefixIcon == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(left: 12, right: 10),
              child: prefixIcon,
            ),
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: DS.primaryLight.withOpacity(0.55),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: DS.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: DS.primary, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: DS.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: DS.error, width: 1),
      ),
    );
  }

  // Button
  static final ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: DS.primary,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    elevation: 0,
  );
}

class DSText {
  const DSText();

  TextStyle get screenTitle => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: DS.textPrimary,
        height: 1.25,
      );

  TextStyle get cardTitle => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: DS.textPrimary,
        height: 1.25,
      );

  TextStyle get primary => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: DS.textPrimary,
        height: 1.35,
      );

  TextStyle get secondary => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: DS.textSecondary,
        height: 1.35,
      );

  TextStyle get label => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: DS.textSecondary,
        height: 1.2,
      );
}
