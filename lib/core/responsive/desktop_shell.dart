import 'package:flutter/material.dart';

import 'desktop_header.dart';
import 'desktop_right_panel.dart';
import 'desktop_sidebar.dart';
import '../routes/app_routes.dart';

class DesktopShell extends StatelessWidget {
  final String currentLocation;
  final Widget child;

  const DesktopShell({
    super.key,
    required this.currentLocation,
    required this.child,
  });

  double _getMaxContentWidth(String route) {
    switch (route) {
      case AppRoutes.home:
        return 650.0;
      case AppRoutes.explore:
        return 920.0;
      case AppRoutes.auditions:
        return 860.0;
      case AppRoutes.artistProfile:
      case AppRoutes.subscription:
      case AppRoutes.editArtistProfile:
        return 840.0;
      case AppRoutes.messages:
        return 1200.0;
      default:
        return 800.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    // Show right panel when there's comfortable space (>= 1160px)
    final showRightPanel = screenWidth >= 1160 &&
        (currentLocation == AppRoutes.home ||
            currentLocation == AppRoutes.auditions ||
            currentLocation == AppRoutes.explore);

    final maxContentWidth = _getMaxContentWidth(currentLocation);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // ── Fixed Top Header ─────────────────────────────────
          const DesktopHeader(),

          // ── Desktop 2/3 Column Layout ────────────────────────
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Left Vertical Sidebar
                DesktopSidebar(currentLocation: currentLocation),

                // 2. Centered Main Content Area
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      child: child,
                    ),
                  ),
                ),

                // 3. Right Information Panel (Stats, Trending Auditions)
                if (showRightPanel) const DesktopRightPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
