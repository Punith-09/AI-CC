import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

import '../../data/models/portfolio_model.dart';

class PortfolioCard extends StatelessWidget {
  final PortfolioModel item;

  const PortfolioCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),

      child: Stack(
        children: [

          Positioned.fill(
            child: Image.asset(
              item.image,
              fit: BoxFit.cover,
            ),
          ),

          if (item.isVideo)
            const Center(
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 48,
              ),
            ),

          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.border,
                ),

                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}