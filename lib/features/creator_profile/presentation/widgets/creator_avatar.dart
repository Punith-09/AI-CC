import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class CreatorAvatar extends StatelessWidget {
  const CreatorAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [

          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary,
                width: 3,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                "assets/images/profile1.jpeg",
                fit: BoxFit.cover,
              ),
            ),
          ),

          Positioned(
            right: 2,
            bottom: 8,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.background,
                  width: 3,
                ),
              ),
              child: const Icon(
                Icons.verified,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}