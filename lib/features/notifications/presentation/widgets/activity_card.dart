import 'package:aicc/core/responsive/responsive_breakpoints.dart';
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
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);

    return Container(
      decoration: BoxDecoration(
        color: isDesktop ? Colors.white : const Color(0xFF0B1F2A),
        borderRadius: BorderRadius.circular(18),
        border: isDesktop ? Border.all(color: const Color(0xFFE2E8F0)) : null,
        boxShadow: isDesktop
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
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
                    backgroundColor: isDesktop ? const Color(0xFFF1F5F9) : Colors.grey,
                    child: Icon(
                      Icons.person,
                      color: isDesktop ? const Color(0xFF64748B) : Colors.white,
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
                                  color: isDesktop ? const Color(0xFF0F172A) : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            Text(
                              activity.time,
                              style: TextStyle(
                                color: isDesktop ? const Color(0xFF94A3B8) : Colors.white54,
                                fontSize: 12,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          activity.subtitle,
                          style: TextStyle(
                            color: isDesktop ? const Color(0xFF64748B) : Colors.white70,
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
                    color: isDesktop ? const Color(0xFF94A3B8) : Colors.white30,
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
