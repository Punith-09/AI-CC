import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';

class CustomBottomNavbar extends StatelessWidget {
  const CustomBottomNavbar({super.key});

  int _currentIndex(String location) {
    switch (location) {
      case '/home':
        return 0;
      case '/explore':
        return 1;
      case '/post':
        return 2;
      case '/auditions':
        return 3;
      case '/artistProfile':
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _currentIndex(location);

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
                      selected: currentIndex == 0,
                      onTap: () => context.go('/home'),
                    ),
                  ),

                  Expanded(
                    child: _NavItem(
                      icon: Icons.search,
                      label: "Explore",
                      selected: currentIndex == 1,
                      onTap: () => context.go('/explore'),
                    ),
                  ),


                  const SizedBox(width: 70),


                  Expanded(
                    child: _NavItem(
                      icon: Icons.mic_none,
                      label: "Auditions",
                      selected: currentIndex == 3,
                      onTap: () => context.go('/auditions'),
                    ),
                  ),

                  Expanded(
                    child: _NavItem(
                      icon: Icons.person_outline,
                      label: "Profile",
                      selected: currentIndex == 4,
                      onTap: () => context.go('/artistProfile'),
                    ),
                  ),
                ],
              ),
            ),
          ),


          Positioned(
            top: -8,
            child: GestureDetector(
              onTap: () => context.go('/post'),
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
                    color: Colors.white.withOpacity(0.2),
                    width: 2,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.6),
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
              color: selected
                  ? AppColors.primary
                  : AppColors.hint,
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: selected
                    ? AppColors.primary
                    : AppColors.hint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}