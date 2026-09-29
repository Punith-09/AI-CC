import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import '../../data/models/activity_model.dart';

class ActivityCard extends StatelessWidget {
  final ActivityModel activity;

  const ActivityCard({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final cardBorder = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
    final titleColor = isDark ? AppColors.darkText : const Color(0xFF0F172A);
    final subtitleColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final timeColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8);
    final avatarBg = isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9);
    final avatarIconColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final chevronColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (activity.highlight)
            Container(
              width: 4,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: avatarBg,
                    child: Icon(
                      Icons.person,
                      color: avatarIconColor,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                activity.title,
                                style: TextStyle(
                                  color: titleColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            Text(
                              activity.time,
                              style: TextStyle(
                                color: timeColor,
                                fontSize: 12,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          activity.subtitle,
                          style: TextStyle(
                            color: subtitleColor,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: activity.badgeColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            activity.badge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: chevronColor,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
