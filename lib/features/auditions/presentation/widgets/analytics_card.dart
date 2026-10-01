import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/routes/app_routes.dart';

class AnalyticsCard extends StatelessWidget {
  final int appliedCount;

  const AnalyticsCard({
    super.key,
    required this.appliedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 185,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image from assets
            Image.asset(
              'assets/images/audition.png',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFF1C1309),
              ),
            ),

            // Dark gradient overlay to keep text and stats sharp and readable
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.90),
                    Colors.black.withValues(alpha: 0.65),
                    Colors.black.withValues(alpha: 0.20),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),

            // Card Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Title Header
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Audition Analysis",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Protagonist:\nShadow of Mumbai",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),

                  // Bottom 3 Stats Row
                  Row(
                    children: [
                      // 1. Applied
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            context.push(AppRoutes.appliedAuditions);
                          },
                          child: _buildStatItem(
                            icon: LucideIcons.users,
                            value: appliedCount.toString(),
                            label: "Applied",
                          ),
                        ),
                      ),

                      // Divider 1
                      _buildDivider(),

                      // 2. Top Fits
                      Expanded(
                        child: _buildStatItem(
                          icon: LucideIcons.trendingUp,
                          value: "12",
                          label: "Top fits",
                        ),
                      ),

                      // Divider 2
                      _buildDivider(),

                      // 3. Avg Match
                      Expanded(
                        child: _buildStatItem(
                          icon: LucideIcons.check,
                          value: "84%",
                          label: "Avg Match",
                          iconColor: const Color(0xFFFF9500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: const Color(0xFF8B6425).withValues(alpha: 0.45),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    Color? iconColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Circular Icon Container
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color: iconColor ?? Colors.white.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 6),

        // Stat Number
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),

        // Stat Label
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.70),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
