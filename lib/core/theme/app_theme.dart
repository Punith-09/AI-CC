// import 'package:flutter/material.dart';
//
// import 'app_colors.dart';
//
// class AppTheme {
//   static ThemeData darkTheme = ThemeData(
//     colorScheme: const ColorScheme.dark(
//       primary: Color(0xFF8E3CF7),
//       secondary: Color(0xFFE940B7),
//     ),
//     textTheme: const TextTheme(
//       displayLarge: TextStyle(color: Colors.white),
//       displayMedium: TextStyle(color: Colors.white),
//       displaySmall: TextStyle(color: Colors.white),
//
//       headlineLarge: TextStyle(color: Colors.white),
//       headlineMedium: TextStyle(color: Colors.white),
//       headlineSmall: TextStyle(color: Colors.white),
//
//       titleLarge: TextStyle(color: Colors.white),
//       titleMedium: TextStyle(color: Colors.white),
//       titleSmall: TextStyle(color: Colors.white),
//
//       bodyLarge: TextStyle(color: Colors.white),
//       bodyMedium: TextStyle(color: Colors.white),
//       bodySmall: TextStyle(color: Colors.white70),
//
//       labelLarge: TextStyle(color: Colors.white),
//       labelMedium: TextStyle(color: Colors.white70),
//       labelSmall: TextStyle(color: Colors.white54),
//     ),
//     useMaterial3: true,
//     scaffoldBackgroundColor: AppColors.background,
//   );
// }



import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    fontFamily: 'Poppins',

    scaffoldBackgroundColor: AppColors.scaffold,

    primaryColor: AppColors.primary,

    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.card,
      onSurface: AppColors.black,
      onPrimary: Colors.white,
      error: AppColors.danger,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.black,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(
        color: AppColors.black,
      ),
      titleTextStyle: TextStyle(
        color: AppColors.black,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        fontFamily: 'Poppins',
      ),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.bold,
      ),

      displayMedium: TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.bold,
      ),

      headlineLarge: TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.w700,
      ),

      headlineMedium: TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.w600,
      ),

      titleLarge: TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.w600,
      ),

      titleMedium: TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.w500,
      ),

      bodyLarge: TextStyle(
        color: AppColors.black,
      ),

      bodyMedium: TextStyle(
        color: AppColors.blackShade,
      ),

      bodySmall: TextStyle(
        color: AppColors.greyText,
      ),

      labelLarge: TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.w600,
      ),
    ),

    iconTheme: const IconThemeData(
      color: AppColors.black,
      size: 24,
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
    ),

    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.textField,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),

      hintStyle: const TextStyle(
        color: AppColors.hint,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonPrimary,
        foregroundColor: Colors.white,

        minimumSize: const Size(double.infinity, 52),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),

        elevation: 0,

        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          fontFamily: 'Poppins',
        ),
      ),
    ),
  );

  /// Alias for backward compatibility ensuring entire app renders in white theme
  static ThemeData get darkTheme => lightTheme;
}