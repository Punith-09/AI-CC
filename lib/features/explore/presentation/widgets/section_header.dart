import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        const Text(
          "TOP MATCHES NEAR YOU",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),

        const Spacer(),

        Icon(
          LucideIcons.mapPin,
          color: AppColors.primary,
          size: 18,
        ),

        const SizedBox(width: 6),

        const Text(
          "Mumbai",
          style: TextStyle(
            color: AppColors.greyText,
          ),
        )
      ],
    );
  }
}