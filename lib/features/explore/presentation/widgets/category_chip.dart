import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

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
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: title.isEmpty ? 18 : 24,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.border.withOpacity(.5),
          ),
        ),
        child: icon != null
            ? Icon(
          icon,
          color: isSelected
              ? AppColors.primary
              : AppColors.greyText,
          size: 22,
        )
            : Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : AppColors.greyText,
          ),
        ),
      ),
    );
  }
}