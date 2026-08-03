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

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    fontFamily: 'Poppins',

    scaffoldBackgroundColor: AppColors.scaffold,

    primaryColor: AppColors.primary,

    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.card,
      error: Colors.redAccent,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),

      displayMedium: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),

      headlineLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),

      headlineMedium: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),

      titleLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),

      titleMedium: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),

      bodyLarge: TextStyle(
        color: Colors.white,
      ),

      bodyMedium: TextStyle(
        color: Colors.white70,
      ),

      bodySmall: TextStyle(
        color: AppColors.greyText,
      ),

      labelLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),

    iconTheme: const IconThemeData(
      color: Colors.white,
      size: 24,
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: .5,
    ),

    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
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
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),

      hintStyle: const TextStyle(
        color: AppColors.greyText,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,

        minimumSize: const Size(double.infinity, 52),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),

        elevation: 0,

        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
  );
}