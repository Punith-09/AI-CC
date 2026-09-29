import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String title;

  const StatItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 28,
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: TextStyle(
              color: isDark ? AppColors.darkText : const Color(0xFF0F172A),
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            title,
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}