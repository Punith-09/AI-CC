import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class CategoryChip extends StatelessWidget {
  final String title;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.title,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedBg = isDark ? AppColors.darkCard : const Color(0xFFF1F5F9);
    final unselectedBorder = isDark ? AppColors.darkBorder : AppColors.whiteShade;
    final unselectedText = isDark ? AppColors.darkTextSecondary : const Color(0xFF475569);
    final unselectedIcon = isDark ? AppColors.darkTextSecondary : AppColors.greyText;

    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: title.isEmpty ? 18 : 20,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF8E3CF7)
              : unselectedBg,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF8E3CF7)
                : unselectedBorder,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF8E3CF7).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: icon != null
            ? Icon(
                icon,
                color: isSelected ? Colors.white : unselectedIcon,
                size: 20,
              )
            : Text(
                title,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : unselectedText,
                ),
              ),
      ),
    );
  }
}
