import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

import 'stat_item.dart';

class StatsCard extends StatelessWidget {
  final int? projects;
  final String? followers;
  final int? awards;

  const StatsCard({super.key, this.projects, this.followers, this.awards});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 24,
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border.withOpacity(.6),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(.08),
            blurRadius: 20,
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            StatItem(
              icon: Icons.work_outline,
              iconColor: const Color(0xff8A2BE2),
              value: projects != null ? projects.toString() : "120+",
              title: "Projects",
            ),
            VerticalDivider(
              color: AppColors.border.withOpacity(.5),
              thickness: 1,
            ),
            StatItem(
              icon: Icons.groups_2_outlined,
              iconColor: const Color(0xffFF4FA3),
              value: followers?.isNotEmpty == true ? followers! : "0",
              title: "Followers",
            ),
            VerticalDivider(
              color: AppColors.border.withOpacity(.5),
              thickness: 1,
            ),
            StatItem(
              icon: Icons.emoji_events_outlined,
              iconColor: const Color(0xff00E5FF),
              value: awards != null ? awards.toString() : "8",
              title: "Awards",
            ),
          ],
        ),
      ),
    );
  }
}