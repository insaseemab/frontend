import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF6B4F3F);
  static const Color accent = Color(0xFFF5F5DC);  
  static const Color secondary = Colors.white;

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