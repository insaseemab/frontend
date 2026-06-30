import 'package:flutter/material.dart';

class AppColors {
  // Brand palette
  static const Color darkBrown = Color(0xFF622B14);
  static const Color sageGreen = Color(0xFFB0BA99);
  static const Color mediumBrown = Color(0xFF9D6638);
  static const Color beige = Color(0xFFF3E4C9);

  static const Color white = Colors.white;
  static const Color black = Colors.black;
}

class AppTheme {
  // Core roles — brown + beige as primary identity
  static const Color primary = AppColors.darkBrown;       // strong brown
  static const Color secondary = AppColors.mediumBrown;   // lighter brown accent
  static const Color background = AppColors.white;        // white scaffold
  static const Color surface = AppColors.beige;           // beige cards/inputs/sheets
  static const Color error = Color(0xFFB3261E);

  static const ColorScheme colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: AppColors.white,
    secondary: secondary,
    onSecondary: AppColors.white,
    error: error,
    onError: AppColors.white,
    surface: surface,
    onSurface: AppColors.black,
    surfaceContainerHighest: AppColors.sageGreen, // optional accent surface variant
    onSurfaceVariant: AppColors.black,
    outline: AppColors.mediumBrown,
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    primaryColor: primary,
    scaffoldBackgroundColor: background,

    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
    ),

    cardTheme: CardThemeData(
      color: surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: secondary),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface, // beige
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.mediumBrown),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.darkBrown, width: 2),
      ),
    ),

    textTheme: const TextTheme(
      headlineSmall: TextStyle(color: AppColors.darkBrown, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: AppColors.darkBrown, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(color: Colors.black87),
      bodySmall: TextStyle(color: Colors.black54),
    ),

    iconTheme: const IconThemeData(color: AppColors.darkBrown),

    dividerTheme: const DividerThemeData(color: AppColors.sageGreen, thickness: 1),
  );
}