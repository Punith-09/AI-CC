import 'package:flutter/material.dart';

class ResponsiveBreakpoints {
  ResponsiveBreakpoints._();

  /// Desktop breakpoint: 1024px
  static const double desktop = 1024.0;

  /// Large desktop / wide screen breakpoint: 1366px - 1440px
  static const double desktopWide = 1366.0;

  /// Returns true if the screen width is >= 1024px
  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= desktop;
  }

  /// Returns true if the screen width is < 1024px
  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < desktop;
  }

  /// Returns true if the screen width is >= 1366px
  static bool isDesktopWide(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= desktopWide;
  }
}
