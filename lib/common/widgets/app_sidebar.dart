import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../features/artist_profile/presentation/providers/profile_provider.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/explore/presentation/providers/explore_provider.dart';
import '../../features/home/presentation/providers/home_feed_provider.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  Future<void> _performLogout(BuildContext context) async {
    // Capture all providers & router before any async gaps
    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final homeFeedProvider = context.read<HomeFeedProvider>();
    final exploreProvider = context.read<ExploreProvider>();
    final router = GoRouter.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Close the drawer first
    Navigator.of(context).pop();

    final bgColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white60 : Colors.black54;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white12 : const Color(0xFFE5E7EB),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child:  Icon(
                  Icons.logout_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Logout',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to log out?',
                textAlign: TextAlign.center,
                style: TextStyle(color: subColor, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.primary,
                        ),
                        foregroundColor: textColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: isDark?AppColors.black:AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) return;

    try {
      await authProvider.logout();
      profileProvider.clear();
      homeFeedProvider.clear();
      exploreProvider.clearForLogout();
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      router.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0D0D0D) : Colors.white;
    final titleColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subtitleColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE5E7EB);
    final itemHoverColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : const Color(0xFFF9FAFB);

    Widget buildSectionItem({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
      Color? iconColor,
      Color? labelColor,
    }) {
      final resolvedIcon = iconColor ?? AppColors.primary;
      final resolvedLabel = labelColor ?? titleColor;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          highlightColor: itemHoverColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: resolvedIcon.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: resolvedIcon, size: 19),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: resolvedLabel,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: subtitleColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Drawer(
      backgroundColor: bgColor,
      width: MediaQuery.of(context).size.width * 0.82,
      // shape: const RoundedRectangleBorder(
      //   borderRadius: BorderRadius.only(
      //     topRight: Radius.circular(24),
      //     bottomRight: Radius.circular(24),
      //   ),
      // ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account & Settings',
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage your preferences',
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // IconButton(
                  //   onPressed: () => Navigator.of(context).pop(),
                  //   icon: Icon(
                  //     Icons.close_rounded,
                  //     color: subtitleColor,
                  //     size: 22,
                  //   ),
                  // ),
                ],
              ),
            ),

            Divider(height: 1, color: dividerColor),

            // ── Top section items ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
              child: Column(
                children: [
                  buildSectionItem(
                    icon: Icons.lock_outline_rounded,
                    label: 'Change Password',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push(AppRoutes.changePassword);
                    },
                  ),
                  buildSectionItem(
                    icon: Icons.bar_chart_rounded,
                    label: 'Live Stats',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push(AppRoutes.liveStats);
                    },
                  ),
                ],
              ),
            ),

            // ── Spacer pushes bottom items to the bottom ───────────
            const Spacer(),

            Divider(height: 1, color: dividerColor),

            // ── Bottom section (destructive actions) ───────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              child: Column(
                children: [
                  buildSectionItem(
                    icon: Icons.delete_outline_rounded,
                    label: 'Delete Account',
                    iconColor: AppColors.danger,
                    labelColor: AppColors.danger,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push(AppRoutes.deleteAccount);
                    },
                  ),
                  buildSectionItem(
                    icon: Icons.logout_rounded,
                    label: 'Logout',
                    iconColor: AppColors.primary,
                    labelColor: titleColor,
                    onTap: () => _performLogout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
