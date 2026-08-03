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
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            title,
            style: const TextStyle(
              color: AppColors.greyText,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}