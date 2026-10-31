import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryPink = Color(0xFFF8DCE5);
  static const Color lavender = Color(0xFFE8DDF5);
  static const Color cream = Color(0xFFFFF5E6);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF554B5C);
  static const Color softPink = Color(0xFFFFEEF3);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: cream,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryPink,
      primary: primaryPink,
      secondary: lavender,
      surface: white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: cream,
      foregroundColor: textDark,
      elevation: 0,
      centerTitle: false,
    ),
    fontFamily: 'Roboto',
  );
}