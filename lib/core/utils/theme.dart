import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  AppColors._();

  static const Color Brown = Color(0xFF795548); // matches Colors.brown
  static const Color sageGreen = Color(0xFFB0BA99);
  static const Color mediumBrown = Color(0xFF9D6638);
  static const Color beige = Color(0xFFF5EFE6);
  static const Color borderBrown = Color(0xFF9D6638);
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  static const Color earningsOrange = Color(0xFFC48A6A);
  static const Color earningsGreen = Color(0xFF6B7D6B);

  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFB3261E);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1565C0);

  static Color cardFill = beige.withOpacity(0.90);
  static Color cardBorder = borderBrown.withOpacity(0.35);
  static Color inputFill = beige.withOpacity(0.70);
  static Color inputBorder = borderBrown.withOpacity(0.45);
  static Color overlayLight = beige.withOpacity(0.55);
  static Color navActive = beige.withOpacity(0.80);
  static Color labelSecondary = Brown.withOpacity(0.65);
  static Color hintText = Brown.withOpacity(0.60);
  static Color iconMuted = Brown.withOpacity(0.75);
  static Color divider = Brown.withOpacity(0.15);
}

class AppGradients {
  AppGradients._();

  static const LinearGradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.sageGreen, AppColors.mediumBrown],
  );

  static LinearGradient cardOverlay = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.beige.withOpacity(0.35),
      AppColors.mediumBrown.withOpacity(0.15),
    ],
  );
}

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle heading1 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.Brown,
    letterSpacing: 0.3,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.Brown,
    letterSpacing: 0.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.Brown,
    letterSpacing: 0.3,
  );

  static const TextStyle heading4 = TextStyle(
    fontSize: 14.5,
    fontWeight: FontWeight.bold,
    color: AppColors.Brown,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 14,
    color: AppColors.Brown,
    height: 1.5,
  );

  static TextStyle bodyMedium = TextStyle(
    fontSize: 13.5,
    color: AppColors.Brown.withOpacity(0.85),
    height: 1.5,
  );

  static TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.Brown.withOpacity(0.65),
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    color: AppColors.Brown,
    letterSpacing: 0.2,
  );

  static TextStyle labelMuted = TextStyle(
    fontSize: 13,
    color: AppColors.Brown.withOpacity(0.75),
  );

  static TextStyle hint = TextStyle(
    fontSize: 14,
    color: AppColors.Brown.withOpacity(0.60),
  );

  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    letterSpacing: 0.3,
  );

  static TextStyle sectionTitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.Brown.withOpacity(0.80),
    letterSpacing: 0.3,
  );

  static const TextStyle splashTitle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 56,
    fontWeight: FontWeight.w300,
    color: AppColors.Brown,
    letterSpacing: 2,
  );

  static const TextStyle splashSubtitle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.Brown,
    letterSpacing: 0.5,
  );

  static const TextStyle splashLoading = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppColors.Brown,
    letterSpacing: 1,
  );
}

class AppDecorations {
  AppDecorations._();

  /// Standard card — used by Admin, NotificationSettings, etc.
  static BoxDecoration card = BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.cardBorder),
    boxShadow: [
      BoxShadow(
        color: AppColors.Brown.withOpacity(0.07),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
    ],
  );

  static BoxDecoration inputField = BoxDecoration(
    color: AppColors.inputFill,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: AppColors.inputBorder),
  );

  static BoxDecoration pill = BoxDecoration(
    color: AppColors.overlayLight,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.mediumBrown.withOpacity(0.50)),
  );

  static BoxDecoration iconButton = BoxDecoration(
    color: AppColors.beige.withOpacity(0.40),
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: AppColors.mediumBrown.withOpacity(0.50)),
  );

  static const BoxDecoration gradientBackground = BoxDecoration(
    gradient: AppGradients.background,
  );
}

class AppButtonStyles {
  AppButtonStyles._();

  /// Primary elevated button used across all auth screens.
  static ButtonStyle primary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.Brown,
    foregroundColor: AppColors.white,
    elevation: 0,
    minimumSize: const Size(double.infinity, 50),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: BorderSide(color: AppColors.mediumBrown.withOpacity(0.70)),
    ),
  );


  static ButtonStyle ghost = TextButton.styleFrom(
    padding: EdgeInsets.zero,
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    foregroundColor: AppColors.Brown,
  );
}


ThemeData get appTheme {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',

    colorScheme: ColorScheme.light(
      primary: AppColors.Brown,
      secondary: AppColors.mediumBrown,
      surface: AppColors.beige,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.Brown,
      error: AppColors.error,
    ),

    scaffoldBackgroundColor: AppColors.white,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.beige,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: AppColors.Brown),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.Brown,
        letterSpacing: 0.3,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.beige.withOpacity(0.55),

      hintStyle: AppTextStyles.hint,

      labelStyle: TextStyle(color: AppColors.Brown.withOpacity(0.8)),

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.mediumBrown.withOpacity(0.6)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.Brown, width: 2),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: AppButtonStyles.primary,
    ),

    textButtonTheme: TextButtonThemeData(style: AppButtonStyles.ghost),

    checkboxTheme: CheckboxThemeData(
      checkColor: WidgetStateProperty.all(AppColors.white),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.mediumBrown;
        return Colors.transparent;
      }),
      side: BorderSide(
        color: AppColors.Brown.withOpacity(0.70),
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.white;
        return AppColors.Brown.withOpacity(0.40);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.Brown.withOpacity(0.65);
        }
        return AppColors.Brown.withOpacity(0.15);
      }),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),

    dividerTheme: DividerThemeData(
      color: AppColors.Brown.withOpacity(0.15),
      thickness: 1,
      space: 1,
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.beige.withOpacity(0.97),
      contentTextStyle: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.Brown,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.Brown,
      linearMinHeight: 2.5,
    ),

    iconTheme: IconThemeData(
      color: AppColors.Brown.withOpacity(0.75),
      size: 20,
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.white,
      indicatorColor: AppColors.navActive,
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final bool selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 11.5,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: AppColors.Brown,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final bool selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: AppColors.Brown,
          size: selected ? 22 : 20,
        );
      }),
    ),
  );
}