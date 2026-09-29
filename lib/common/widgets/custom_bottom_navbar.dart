import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../features/create/presentation/widgets/create_bottom_sheet.dart';

class CustomBottomNavbar extends StatelessWidget {
  final String currentLocation;
  final ValueChanged<String> onItemSelected;

  const CustomBottomNavbar({
    super.key,
    required this.currentLocation,
    required this.onItemSelected,
  });

  int get currentIndex {
    switch (currentLocation) {
      case AppRoutes.home:
        return 0;
      case AppRoutes.explore:
        return 1;
      case AppRoutes.post:
        return 2;
      case AppRoutes.auditions:
        return 3;
      case AppRoutes.artistProfile:
      case AppRoutes.subscription:
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final index = currentIndex;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 82,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
            Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.divider,
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _NavItem(
                      icon: LucideIcons.home,
                      label: "Home",
                      selected: index == 0,
                      onTap: () => onItemSelected(AppRoutes.home),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: LucideIcons.search,
                      label: "Explore",
                      selected: index == 1,
                      onTap: () => onItemSelected(AppRoutes.explore),
                    ),
                  ),
                  const SizedBox(width: 70),
                  Expanded(
                    child: _NavItem(
                      icon: LucideIcons.clapperboard,
                      label: "Auditions",
                      selected: index == 3,
                      onTap: () => onItemSelected(AppRoutes.auditions),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: LucideIcons.userRound,
                      label: "Profile",
                      selected: index == 4,
                      onTap: () => onItemSelected(AppRoutes.artistProfile),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -8,
            child: GestureDetector(
              onTap: () async {
                final route = await showModalBottomSheet<String>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  barrierColor: Colors.black.withValues(alpha: 0.65),
                  builder: (context) {
                    return const CreateBottomSheet();
                  },
                );
                if (route != null && context.mounted) {
                  context.push(route);
                }
              },
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.buttonPrimary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.buttonPrimary.withValues(alpha: 0.35),
                      blurRadius: 14,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  size: 34,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedColor = isDark ? AppColors.darkTextSecondary : AppColors.hint;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: selected ? AppColors.primary : unselectedColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: selected ? AppColors.primary : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}