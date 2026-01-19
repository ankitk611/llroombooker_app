part of 'values.dart';

class Styles {

  static TextStyle greySubtitleTextStyle({
    Color color = const Color.fromARGB(255, 96, 96, 97),
    FontWeight fontWeight = FontWeight.w600,
    required double fontSize,
    FontStyle fontStyle= FontStyle.normal,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
    );
  }

  static TextStyle greySubtitleTextStyle2({
    Color color = const Color.fromARGB(255, 96, 96, 97),
    FontWeight fontWeight = FontWeight.w500,
    required double fontSize,
    FontStyle fontStyle= FontStyle.normal,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
    );
  }

  static TextStyle blackTitleTextStyle({
    Color color = const Color.fromARGB(255, 10, 10, 10),
    FontWeight fontWeight = FontWeight.w800,
    required double fontSize,
    FontStyle fontStyle= FontStyle.normal,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
    );
  }

  static TextStyle blueTitleTextStyle({
    Color color = const Color.fromARGB(255, 0, 2, 97),
    FontWeight fontWeight = FontWeight.w700,
    required double fontSize,
    FontStyle fontStyle= FontStyle.normal,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
    );
  }
  static TextStyle whiteTitleTextStyle({
    Color color = const Color.fromARGB(255, 252, 252, 252),
    FontWeight fontWeight = FontWeight.w700,
    required double fontSize,
    FontStyle fontStyle= FontStyle.normal,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
    );
  }
  static TextStyle whiteSubtitleTextStyle({
    Color color = const Color.fromARGB(255, 255, 255, 255),
    FontWeight fontWeight = FontWeight.w600,
    required double fontSize,
    FontStyle fontStyle= FontStyle.normal,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
    );
  }
  
}
