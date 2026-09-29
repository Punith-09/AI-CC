import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  /// Primary Brand Color
  static const Color primary = Color(0xFF7C3AED);
  static const Color buttonPrimary = Color(0xFF7C3AED);
  static const Color secondary = Color(0xFF6D28D9);
  static const Color gradient = Color(0xFF7C3AED);

  // ============================================================
  // LIGHT PALETTE
  // ============================================================
  static const Color lightScaffold = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextField = Color(0xFFF3F4F6);
  static const Color lightText = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF4B5563);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightDivider = Color(0xFFE5E7EB);

  // ============================================================
  // DARK PALETTE
  // ============================================================
  // static const Color darkScaffold = Color(0xFF0F172A);
  static const Color darkScaffold = Color(0xFF000000);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkCardHover = Color(0xFF334155);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkTextField = Color(0xFF334155);
  static const Color darkText = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkDivider = Color(0xFF334155);

  // ============================================================
  // LEGACY STATIC CONSTANTS (for backward compatibility)
  // ============================================================
  static const List<Color> backGroundGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFFFFFFF),
    Color(0xFFFFFFFF),
  ];

  static const List<Color> authBtnGradient = [
    buttonPrimary,
    buttonPrimary,
  ];

  static const List<Color> BtnGradient = [
    buttonPrimary,
    buttonPrimary,
  ];

  static const Color background = Color(0xFF000000);
  static const Color scaffold = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textField = Color(0xFFF3F4F6);
  static const Color logo = Color(0xFF111827);

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

  // ============================================================
  // CENTRALIZED THEME-AWARE COLOR RESOLVERS
  // ============================================================
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color getScaffold(BuildContext context) =>
      isDark(context) ? darkScaffold : lightScaffold;

  static Color getCard(BuildContext context) =>
      isDark(context) ? darkCard : lightCard;

  static Color getSurface(BuildContext context) =>
      isDark(context) ? darkSurface : lightSurface;

  static Color getText(BuildContext context) =>
      isDark(context) ? darkText : lightText;

  static Color getTextSecondary(BuildContext context) =>
      isDark(context) ? darkTextSecondary : lightTextSecondary;

  static Color getBorder(BuildContext context) =>
      isDark(context) ? darkBorder : lightBorder;

  static Color getDivider(BuildContext context) =>
      isDark(context) ? darkDivider : lightDivider;

  static Color getTextField(BuildContext context) =>
      isDark(context) ? darkTextField : lightTextField;
}
