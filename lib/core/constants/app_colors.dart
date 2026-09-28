import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  /// Primary Brand Color
  static const Color primary = Color(0xFF7C3AED);
  static const Color buttonPrimary = Color(0xFF7C3AED);

  static const Color secondary = Color(0xFF6D28D9);

  static const Color gradient = Color(0xFF7C3AED);

  /// Solid White Backgrounds (replaces dark gradients)
  static const List<Color> backGroundGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFFFFFFF),
    Color(0xFFFFFFFF),
  ];

  /// Fixed Solid Button Colors (replaces gradient buttons)
  static const List<Color> authBtnGradient = [
    buttonPrimary,
    buttonPrimary,
  ];

  static const List<Color> BtnGradient = [
    buttonPrimary,
    buttonPrimary,
  ];

  /// Backgrounds
  static const Color background = Color(0xFFFFFFFF);
  static const Color scaffold = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textField = Color(0xFFF3F4F6);
  static const Color logo = Color(0xFF111827);

  /// Text & Neutrals (Black / Charcoal for maximum contrast on white)
  static const Color black = Color(0xFF111827);
  static const Color blackShade = Color(0xFF1F2937);
  static const Color greyText = Color(0xFF4B5563);
  static const Color grey = Color(0xFF6B7280);
  static const Color hint = Color(0xFF9CA3AF);
  static const Color whiteShade = Color(0xFFAAAAAA);
  static const Color whiteShade1 = Color(0xFFF3F3F3);

  static const Color divider = Color(0xFFE5E7EB);
  static const Color border = Color(0xFFE5E7EB);

  static const Color success = Color(0xFF10B981);
  static const Color white = Color(0xFFFFFFFF);
  static const Color purple = Color(0xFF7C3AED);
  static const Color pink = Color(0xFFEC4899);

  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
}

