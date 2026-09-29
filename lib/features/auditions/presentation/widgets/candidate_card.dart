import 'skill_chip.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'gradient_progress_bar.dart';

class CandidateCard extends StatelessWidget {
  final int rank;
  final String name;
  final String role;
  final String age;
  final int matchScore;
  final List<String> skills;
  final String imageUrl;

  const CandidateCard({
    super.key,
    required this.rank,
    required this.name,
    required this.role,
    required this.age,
    required this.matchScore,
    required this.skills,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final titleColor = isDark ? Colors.white : const Color(0xFF111827);
    final subtitleColor = isDark ? Colors.grey : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border.all(color: cardBorder),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Header
          Row(
            children: [

              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(imageUrl),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      children: [

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            "#$rank",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      name,
                      style: TextStyle(
                        color: titleColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "$role • $age",
                      style: TextStyle(
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.share_outlined,
                  color: Colors.white70,
                ),
              )
            ],
          ),

          const SizedBox(height: 22),

          Text(
            "AI Match Score",
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          GradientProgressBar(
            value: matchScore / 100,
          ),

          const SizedBox(height: 18),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills
                .map(
                  (skill) => SkillChip(
                skill: skill,
                selected: true,
              ),
            )
                .toList(),
          ),

          const SizedBox(height: 24),

          Row(
            children: [

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push('/chat');

                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text("Message"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(
                      color: Colors.white24,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.star),
                  label: const Text("Shortlist"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF3E8FF),
                    foregroundColor: isDark ? Colors.white : const Color(0xFF7C3AED),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}