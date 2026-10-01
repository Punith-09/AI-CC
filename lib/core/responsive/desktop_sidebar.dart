import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../constants/app_colors.dart';
import '../routes/app_routes.dart';
import '../../features/create/presentation/widgets/create_bottom_sheet.dart';

class DesktopSidebar extends StatelessWidget {
  final String currentLocation;

  const DesktopSidebar({
    super.key,
    required this.currentLocation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),

          // ── Primary Navigation Items ──────────────────────────
          _SidebarItem(
            icon: LucideIcons.home,
            label: "Home",
            isSelected: currentLocation == AppRoutes.home,
            onTap: () {
              if (currentLocation != AppRoutes.home) {
                context.go(AppRoutes.home);
              }
            },
          ),
          _SidebarItem(
            icon: LucideIcons.compass,
            label: "Explore",
            isSelected: currentLocation == AppRoutes.explore,
            onTap: () {
              if (currentLocation != AppRoutes.explore) {
                context.go(AppRoutes.explore);
              }
            },
          ),
          _SidebarItem(
            icon: LucideIcons.clapperboard,
            label: "Auditions",
            isSelected: currentLocation == AppRoutes.auditions,
            onTap: () {
              if (currentLocation != AppRoutes.auditions) {
                context.go(AppRoutes.auditions);
              }
            },
          ),
          _SidebarItem(
            icon: LucideIcons.messageSquare,
            label: "Messages",
            isSelected: currentLocation == AppRoutes.messages,
            onTap: () {
              if (currentLocation != AppRoutes.messages) {
                context.go(AppRoutes.messages);
              }
            },
          ),
          _SidebarItem(
            icon: LucideIcons.userRound,
            label: "Profile",
            isSelected: currentLocation == AppRoutes.artistProfile ||
                currentLocation == AppRoutes.subscription,
            onTap: () {
              if (currentLocation != AppRoutes.artistProfile) {
                context.go(AppRoutes.artistProfile);
              }
            },
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              color: isDark ? AppColors.darkDivider : const Color(0xFFE2E8F0),
              thickness: 1,
              height: 1,
            ),
          ),

          const SizedBox(height: 20),

          // ── Create Action Button ──────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final route = await showDialog<String>(
                    context: context,
                    barrierDismissible: true,
                    barrierColor: Colors.black.withValues(alpha: 0.65),
                    builder: (dialogContext) {
                      return Dialog(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        insetPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 40,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 560,
                          ),
                          child: const CreateBottomSheet(),
                        ),
                      );
                    },
                  );

                  if (route != null && context.mounted) {
                    context.push(route);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonPrimary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: Text(
                  "New Post / Audition",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          const Spacer(),

          // ── Secondary Navigation / Manage ─────────────────────
          // _SidebarSubItem(
          //   icon: LucideIcons.crown,
          //   label: "Subscription",
          //   onTap: () => context.push(AppRoutes.subscription),
          // ),
          // _SidebarSubItem(
          //   icon: LucideIcons.bookmark,
          //   label: "Applied Auditions",
          //   onTap: () => context.push(AppRoutes.appliedAuditions),
          // ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final active = widget.isSelected;
    final primaryColor = AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: active
                  ? (isDark ? AppColors.primary.withValues(alpha: 0.2) : const Color(0xFFF3E8FF))
                  : (_isHovered ? (isDark ? AppColors.darkCardHover : const Color(0xFFF8FAFC)) : Colors.transparent),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: 20,
                  color: active
                      ? primaryColor
                      : (isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B)),
                ),
                const SizedBox(width: 14),
                Text(
                  widget.label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    color: active
                        ? primaryColor
                        : (isDark ? AppColors.darkText : const Color(0xFF334155)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarSubItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SidebarSubItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            children: [
              Icon(
                icon,
                size: 17,
                color: isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
