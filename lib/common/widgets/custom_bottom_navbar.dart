import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';

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
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final index = currentIndex;

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
              decoration: const BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _NavItem(
                      icon: Icons.home_outlined,
                      label: "Home",
                      selected: index == 0,
                      onTap: () => onItemSelected(AppRoutes.home),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.search,
                      label: "Explore",
                      selected: index == 1,
                      onTap: () => onItemSelected(AppRoutes.explore),
                    ),
                  ),
                  const SizedBox(width: 70),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.mic_none,
                      label: "Auditions",
                      selected: index == 3,
                      onTap: () => onItemSelected(AppRoutes.auditions),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.person_outline,
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
              onTap: () => onItemSelected(AppRoutes.post),
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.primary,
                      AppColors.secondary,
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.6),
                      blurRadius: 18,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
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
              color: selected ? AppColors.primary : AppColors.hint,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: selected ? AppColors.primary : AppColors.hint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}