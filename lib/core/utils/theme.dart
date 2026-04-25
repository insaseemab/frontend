import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = const Color(0xFFF5EFE6);
  static const Color accent = Colors.white;  
  static const Color secondary = Colors.brown;

  static ThemeData lightTheme = ThemeData(
    primaryColor: primary,
    scaffoldBackgroundColor: secondary,

    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: accent,
      surface: secondary,
    ),

    cardColor: Colors.white,

    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black87),
    ),
  );
}