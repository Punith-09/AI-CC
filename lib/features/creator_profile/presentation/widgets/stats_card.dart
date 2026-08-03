import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  const StatsCard({super.key});

  Widget _stat(String value, String title) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.greyText,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),

      padding: const EdgeInsets.symmetric(
        vertical: 24,
      ),

      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border.withOpacity(.4),
        ),
      ),

      child: Row(
        children: [

          _stat("1.2M", "Followers"),

          Container(
            width: 1,
            height: 42,
            color: AppColors.divider,
          ),

          _stat("254", "Following"),

          Container(
            width: 1,
            height: 42,
            color: AppColors.divider,
          ),

          _stat("86", "Projects"),

          Container(
            width: 1,
            height: 42,
            color: AppColors.divider,
          ),

          _stat("18K", "Likes"),
        ],
      ),
    );
  }
}