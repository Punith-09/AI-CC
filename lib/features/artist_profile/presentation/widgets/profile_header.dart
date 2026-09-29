import 'package:aicc/core/constants/app_colors.dart';
import 'package:aicc/core/responsive/responsive_breakpoints.dart';
import 'package:aicc/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileHeader extends StatelessWidget {
  final String? coverImage;
  final bool isOtherUser;

  const ProfileHeader({
    super.key,
    this.coverImage,
    this.isOtherUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // ── Theme Switch Button ──────────────────────────────
          if(!isDesktop)
          Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? AppColors.darkBorder
                    : const Color(0xFFE2E8F0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              tooltip: isDark ? "Switch to Light Theme" : "Switch to Dark Theme",
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: isDark ? const Color(0xFFFBBF24) : AppColors.primary,
                size: 20,
              ),
              onPressed: () {
                context.read<ThemeProvider>().toggleTheme();
              },
            ),
          ),

          if (!isOtherUser)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorder
                      : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                ),
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    LucideIcons.ellipsisVertical,
                    color: isDark ? AppColors.darkText : AppColors.black,
                    size: 22,
                  ),
                  color: isDark ? AppColors.darkCard : Colors.white,
                  elevation: isDesktop ? 6 : 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isDark
                          ? AppColors.darkBorder
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      context.push(AppRoutes.editArtistProfile);
                    } else if (value == 'theme') {
                      context.read<ThemeProvider>().toggleTheme();
                    } else if (value == 'logout') {
                      try {
                        final authProvider = context.read<AuthProvider>();
                        final profileProvider = context.read<ProfileProvider>();
                        await authProvider.logout();
                        profileProvider.clear();
                      } catch (e) {
                        debugPrint('Logout error: $e');
                      } finally {
                        if (context.mounted) {
                          context.go(AppRoutes.welcome);
                        }
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'theme',
                      child: Row(
                        children: [
                          Icon(
                            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                            size: 20,
                            color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF334155),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isDark ? 'Light Theme' : 'Dark Theme',
                            style: TextStyle(
                              color: isDark ? AppColors.darkText : AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: isDark ? AppColors.darkTextSecondary : const Color(0xFF334155),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Edit',
                            style: TextStyle(
                              color: isDark ? AppColors.darkText : AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 20, color: Colors.redAccent),
                          SizedBox(width: 10),
                          Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
