import 'package:flutter/material.dart';

class AppTheme {
  // Primary seed color for Material 3
  static const Color primarySeedColor = Color.fromARGB(255, 3, 70, 164);

  // Simple note colors
  static final List<Color> noteColors = [
    const Color(0xFFF5F5F5), // Off-White
    const Color(0xFFEEEEEE), // Light Gray
    const Color(0xFFE0E0E0), // Lighter Gray
    const Color(0xFFF0F0F0), // Slight Off-White
    const Color(0xFFECEFF1), // Blue Gray Light
    const Color(0xFFFAFAFA), // Nearly White
    const Color(0xFFF8F9FA), // Snow
    Colors.white, // White
  ];

  // Simple light theme using ColorScheme.fromSeed
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primarySeedColor,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: ColorScheme.fromSeed(seedColor: primarySeedColor).primaryContainer,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primarySeedColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}
