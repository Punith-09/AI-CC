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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 24,
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            StatItem(
              icon: Icons.work_outline,
              iconColor: const Color(0xff8A2BE2),
              value: projects != null ? projects.toString() : "0",
              title: "Projects",
            ),
            VerticalDivider(
              color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
              thickness: 1,
            ),
            StatItem(
              icon: Icons.groups_2_outlined,
              iconColor: const Color(0xffFF4FA3),
              value: followers?.isNotEmpty == true ? followers! : "0",
              title: "Followers",
            ),
            VerticalDivider(
              color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
              thickness: 1,
            ),
            StatItem(
              icon: Icons.emoji_events_outlined,
              iconColor: const Color(0xff00E5FF),
              value: awards != null ? awards.toString() : "0",
              title: "Awards",
            ),
          ],
        ),
      ),
    );
  }
}