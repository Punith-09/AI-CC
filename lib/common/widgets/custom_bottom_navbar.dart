import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../features/artist_profile/presentation/providers/profile_provider.dart';
import '../../features/create/presentation/widgets/create_bottom_sheet.dart';
import '../../features/home/presentation/providers/home_feed_provider.dart';

class CustomBottomNavbar extends StatelessWidget {
  final String currentLocation;
  final ValueChanged<String> onItemSelected;
  final Color? backgroundColor;

  const CustomBottomNavbar({
    super.key,
    required this.currentLocation,
    required this.onItemSelected,
    this.backgroundColor,
  });

  int get currentIndex {
    switch (currentLocation) {
      case AppRoutes.home:
        return 0;
      case AppRoutes.videos:
        return 1;
      case AppRoutes.explore:
      case AppRoutes.exploreProfile:
        return 2;
      case AppRoutes.post:
        return 3;
      case AppRoutes.auditions:
        return 4;
      case AppRoutes.artistProfile:
      case AppRoutes.subscription:
      case AppRoutes.editArtistProfile:
        return 5;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final index = currentIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 72 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? AppColors.darkCard : Colors.white),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(0),
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
          // 1. Home
          Expanded(
            child: _NavItem(
              icon: LucideIcons.home,
              label: "Home",
              selected: index == 0,
              onTap: () => onItemSelected(AppRoutes.home),
            ),
          ),

          // 2. Videos (New item after Home)
          Expanded(
            child: _NavItem(
              icon: LucideIcons.playCircle,
              label: "Videos",
              selected: index == 1,
              onTap: () => onItemSelected(AppRoutes.videos),
            ),
          ),

          // 3. Explore
          Expanded(
            child: _NavItem(
              icon: LucideIcons.search,
              label: "Explore",
              selected: index == 2,
              onTap: () => onItemSelected(AppRoutes.explore),
            ),
          ),

          // 4. Post (Regular bottom bar item)
          Expanded(
            child: _NavItem(
              icon: LucideIcons.plusCircle,
              label: "Post",
              selected: index == 3,
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
                  final result = await context.push(route);
                  if (result == true && context.mounted) {
                    try {
                      context.read<ProfileProvider>().fetchMyProfile(silent: true);
                      context.read<HomeFeedProvider>().fetchFeed();
                    } catch (_) {}
                  }
                }
              },
            ),
          ),

          // 5. Auditions
          Expanded(
            child: _NavItem(
              icon: LucideIcons.clapperboard,
              label: "Auditions",
              selected: index == 4,
              onTap: () => onItemSelected(AppRoutes.auditions),
            ),
          ),

          // 6. Profile
          Expanded(
            child: _NavItem(
              icon: LucideIcons.userRound,
              label: "Profile",
              selected: index == 5,
              onTap: () => onItemSelected(AppRoutes.artistProfile),
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
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppColors.primary : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
