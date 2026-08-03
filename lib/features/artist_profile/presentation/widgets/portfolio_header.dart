import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class PortfolioHeader extends StatelessWidget {
  const PortfolioHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        const Text(
          "Portfolio",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const Spacer(),

        TextButton(
          onPressed: () {},

          child: const Text(
            "View All",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}