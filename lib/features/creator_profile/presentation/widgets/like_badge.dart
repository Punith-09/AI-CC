import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class LikeBadge extends StatelessWidget {

  final int likes;

  const LikeBadge({
    super.key,
    required this.likes,
  });

  String _formatLikes(int value) {
    if (value >= 1000000) {
      return "${(value / 1000000).toStringAsFixed(1)}M";
    }

    if (value >= 1000) {
      return "${(value / 1000).toStringAsFixed(1)}K";
    }

    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),

      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.55),
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          const Icon(
            Icons.favorite,
            size: 14,
            color: Colors.red,
          ),

          const SizedBox(width: 5),

          Text(
            _formatLikes(likes),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}