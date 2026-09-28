import 'package:aicc/core/constants/app_colors.dart';
import 'package:aicc/core/responsive/responsive_breakpoints.dart';
import 'package:flutter/material.dart';

import 'stat_item.dart';

class StatsCard extends StatelessWidget {
  final int? projects;
  final String? followers;
  final int? awards;

  const StatsCard({super.key, this.projects, this.followers, this.awards});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 24,
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: isDesktop ? Colors.white : AppColors.card.withOpacity(.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDesktop ? const Color(0xFFE2E8F0) : AppColors.border.withOpacity(.6),
        ),
        boxShadow: isDesktop
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
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
              color: isDesktop ? const Color(0xFFE2E8F0) : AppColors.border.withOpacity(.5),
              thickness: 1,
            ),
            StatItem(
              icon: Icons.groups_2_outlined,
              iconColor: const Color(0xffFF4FA3),
              value: followers?.isNotEmpty == true ? followers! : "125K",
              title: "Followers",
            ),
            VerticalDivider(
              color: isDesktop ? const Color(0xFFE2E8F0) : AppColors.border.withOpacity(.5),
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