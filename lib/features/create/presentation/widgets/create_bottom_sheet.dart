import 'package:aicc/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/responsive/responsive_breakpoints.dart';

class CreateBottomSheet extends StatelessWidget {
  const CreateBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── DESKTOP / WEB VIEW ─────────────────────────────────────────────
    if (isDesktop) {
      final desktopBgColor = isDark ? const Color(0xFF12151D) : Colors.white;
      final desktopTextColor = isDark ? AppColors.darkText : AppColors.lightText;
      final desktopBorderColor = isDark ? const Color(0xFF262E3E) : const Color(0xFFE2E8F0);

      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 440,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: desktopBgColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: desktopBorderColor,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.55 : 0.15),
                  blurRadius: 32,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Desktop Header with title and close icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 32),
                      Text(
                        "Create",
                        style: GoogleFonts.montserrat(
                          color: desktopTextColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close_rounded,
                          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        splashRadius: 18,
                        tooltip: 'Close',
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  _CreateOption(
                    icon: Icons.assignment_outlined,
                    title: 'Post Audition',
                    subtitle: 'Create a casting call',
                    onTap: () => Navigator.pop(context, AppRoutes.post),
                  ),

                  const SizedBox(height: 12),

                  _CreateOption(
                    icon: Icons.video_library_outlined,
                    title: 'Upload Video',
                    subtitle: 'Share your portfolio reel',
                    onTap: () => Navigator.pop(context, AppRoutes.uploadVideo),
                  ),

                  const SizedBox(height: 12),

                  _CreateOption(
                    icon: Icons.photo_camera_outlined,
                    title: 'Upload Photo',
                    subtitle: 'Add to your portfolio',
                    onTap: () => Navigator.pop(context, AppRoutes.uploadPhoto),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // ── MOBILE VIEW (100% UNCHANGED) ──────────────────────────────────
    final bgColor = isDark ? AppColors.darkCard : Colors.white;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final handleColor = isDark ? Colors.white24 : Colors.black12;
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.lightDivider;
    final cancelColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: handleColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Create",
                    style: GoogleFonts.montserrat(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                ],
              ),

              const SizedBox(height: 22),

              _CreateOption(
                icon: Icons.assignment_outlined,
                title: 'Post Audition',
                subtitle: 'Create a casting call',
                onTap: () => Navigator.pop(context, AppRoutes.post),
              ),

              const SizedBox(height: 10),

              _CreateOption(
                icon: Icons.video_library_outlined,
                title: 'Upload Video',
                subtitle: 'Share your portfolio reel',
                onTap: () => Navigator.pop(context, AppRoutes.uploadVideo),
              ),

              const SizedBox(height: 10),

              _CreateOption(
                icon: Icons.photo_camera_outlined,
                title: 'Upload Photo',
                subtitle: 'Add to your portfolio',
                onTap: () => Navigator.pop(context, AppRoutes.uploadPhoto),
              ),

              const SizedBox(height: 18),
              Container(
                height: 1,
                color: dividerColor,
              ),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: cancelColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CreateOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final itemBg = isDark ? (isDesktop ? const Color(0xFF181D27) : AppColors.darkSurface) : const Color(0xFFF8FAFC);
    final itemBorder = isDark ? (isDesktop ? const Color(0xFF2B3346) : AppColors.darkBorder) : const Color(0xFFE2E8F0);
    final titleColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final arrowColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        mouseCursor: isDesktop ? SystemMouseCursors.click : MouseCursor.defer,
        borderRadius: BorderRadius.circular(16),
        hoverColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 16 : 14,
            vertical: isDesktop ? 14 : 13,
          ),
          decoration: BoxDecoration(
            color: itemBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: itemBorder,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.buttonPrimary.withValues(alpha: 0.12),
                  border: Border.all(color: AppColors.buttonPrimary.withValues(alpha: 0.35)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: AppColors.buttonPrimary,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                color: arrowColor,
                size: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}