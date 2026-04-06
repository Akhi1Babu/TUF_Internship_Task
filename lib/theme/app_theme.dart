import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryLight = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color backgroundDark = Color(0xFF111827);
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1F2937);
  static const Color textLight = Color(0xFF111827);
  static const Color textDark = Color(0xFFF9FAFB);
  static const Color expenseColor = Color(0xFFEF4444);
  static const Color incomeColor = Color(0xFF10B981);

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryLight,
    scaffoldBackgroundColor: backgroundLight,
    cardColor: cardLight,
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
      bodyLarge: GoogleFonts.inter(color: textLight),
      bodyMedium: GoogleFonts.inter(color: textLight),
    ),
    colorScheme: const ColorScheme.light(
      primary: primaryLight,
      secondary: primaryDark,
      surface: cardLight,
      error: expenseColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundLight,
      elevation: 0,
      iconTheme: const IconThemeData(color: textLight),
      titleTextStyle: GoogleFonts.inter(
        color: textLight,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryDark,
    scaffoldBackgroundColor: backgroundDark,
    cardColor: cardDark,
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      bodyLarge: GoogleFonts.inter(color: textDark),
      bodyMedium: GoogleFonts.inter(color: textDark),
    ),
    colorScheme: const ColorScheme.dark(
      primary: primaryLight,
      secondary: primaryDark,
      surface: cardDark,
      error: expenseColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundDark,
      elevation: 0,
      iconTheme: const IconThemeData(color: textDark),
      titleTextStyle: GoogleFonts.inter(
        color: textDark,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    useMaterial3: true,
  );
}
