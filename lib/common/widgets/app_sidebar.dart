import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart' show Share;

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../features/artist_profile/presentation/providers/profile_provider.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/explore/presentation/providers/explore_provider.dart';
import '../../features/home/presentation/providers/home_feed_provider.dart';

const String _kAppPlayStoreUrl =
    'https://play.google.com/store/apps/details?id=talentcasting.com&pcampaignid=web_share';

// ===========================================================
// APP SIDEBAR
// ===========================================================

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  Future<void> _performLogout(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final homeFeedProvider = context.read<HomeFeedProvider>();
    final exploreProvider = context.read<ExploreProvider>();
    final router = GoRouter.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                child: const Icon(
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
                        side: const BorderSide(color: AppColors.primary),
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
                        foregroundColor:
                            isDark ? AppColors.black : AppColors.white,
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

  void _showInviteSheet(BuildContext context) {
    Navigator.of(context).pop();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => const _InviteSheet(inviteLink: _kAppPlayStoreUrl),
    );
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
      Widget? badge,
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
                  child: Row(
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: resolvedLabel,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        badge,
                      ],
                    ],
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

    // "NEW" badge pill
    final newBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'NEW',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );

    return Drawer(
      backgroundColor: bgColor,
      width: MediaQuery.of(context).size.width * 0.82,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
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

            Divider(height: 1, color: dividerColor),

            // ── Menu items ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
              child: Column(
                children: [
                  buildSectionItem(
                    icon: Icons.person_add_alt_1_rounded,
                    label: 'Invite Friends',
                    badge: newBadge,
                    onTap: () => _showInviteSheet(context),
                  ),
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

            // ── Push bottom actions to the bottom ──────────────────
            const Spacer(),

            Divider(height: 1, color: dividerColor),

            // ── Destructive actions ────────────────────────────────
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

// ===========================================================
// INVITE FRIENDS BOTTOM SHEET
// ===========================================================

class _InviteSheet extends StatefulWidget {
  final String inviteLink;
  const _InviteSheet({required this.inviteLink});

  @override
  State<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends State<_InviteSheet> {
  bool _copied = false;

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: widget.inviteLink));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  Future<void> _shareLink() async {
    try {
      await Share.share(
        '🎬 Join me on TreeKo – the best casting & talent app!\n\nDownload now: ${widget.inviteLink}',
        subject: 'Join TreeKo – Casting & Talent App',
      );
    } catch (e) {
      debugPrint('Share error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF111827);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final linkBg =
        isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F0FF);
    final linkBorder =
        isDark ? const Color(0xFF3A3A3A) : const Color(0xFFDDD6FE);

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 36,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 22),

          // Title row with Share button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Invite Link',
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Share with friends and grow together',
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Share button (purple pill)
              GestureDetector(
                onTap: _shareLink,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.share_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 7),
                      Text(
                        'Share',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Link box with copy button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: linkBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: linkBorder, width: 1.2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.inviteLink,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Copy button
                GestureDetector(
                  onTap: _copyLink,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _copied
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _copied
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          _copied
                              ? Icons.check_rounded
                              : Icons.copy_rounded,
                          key: ValueKey(_copied),
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // "Copied" feedback
          AnimatedOpacity(
            opacity: _copied ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Center(
              child: Text(
                '✓ Link copied to clipboard',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
