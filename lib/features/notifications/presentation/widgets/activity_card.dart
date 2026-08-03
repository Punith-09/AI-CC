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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1F2A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          if (activity.highlight)
            Container(
              width: 4,
              height: 120,
              color: Colors.amber,
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person),
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
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            Text(
                              activity.time,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          activity.subtitle,
                          style: const TextStyle(
                            color: Colors.white70,
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
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.white30,
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
