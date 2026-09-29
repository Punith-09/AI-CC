import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ActivityTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const ActivityTabBar({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const tabs = ["All", "Matches", "Updates"];

    final containerBg = isDark ? AppColors.darkCard : Colors.white;
    final containerBorder = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
    final unselectedTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: containerBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: containerBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.03),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: List.generate(
            tabs.length,
            (index) => Expanded(
              child: GestureDetector(
                onTap: () => onChanged(index),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: selectedIndex == index
                        ? AppColors.buttonPrimary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      tabs[index],
                      style: TextStyle(
                        color: selectedIndex == index
                            ? Colors.white
                            : unselectedTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
