import 'package:aicc/features/explore/data/models/talent_model.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import 'match_badge.dart';

class TalentCard extends StatelessWidget {

  final TalentModel talent;

  const TalentCard({
    super.key,
    required this.talent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(.25),
        ),
      ),

      clipBehavior: Clip.antiAlias,

      child: Stack(
        children: [

          Positioned.fill(
            child: Image.asset(
              talent.image,
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(.8),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 12,
            left: 12,
            child: MatchBadge(
              match: talent.match,
            ),
          ),

          Positioned(
            left: 14,
            bottom: 14,
            right: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  talent.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  talent.role,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}