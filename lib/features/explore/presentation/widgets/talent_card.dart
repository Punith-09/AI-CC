import 'package:aicc/core/api/api_endpoints.dart';
import 'package:aicc/features/explore/data/models/talent_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';

class TalentCard extends StatelessWidget {
  final TalentModel talent;

  const TalentCard({super.key, required this.talent});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final cardBorder = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
    final nameColor = isDark ? AppColors.darkText : AppColors.lightText;

    final formattedPic = talent.pic.isNotEmpty
        ? ApiEndpoints.formatMediaUrl(talent.pic)
        : '';
    final hasValidNetworkPic = formattedPic.startsWith('http');

    return GestureDetector(
      onTap: () {
        if (talent.id.isNotEmpty) {
          context.push(AppRoutes.exploreProfile, extra: talent.id);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: cardBorder,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (talent.matchPercent > 0)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFD54F),
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${talent.matchPercent}%',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Center Avatar / Silhouette ─────────────────────
            Center(
              child: hasValidNetworkPic
                  ? Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          formattedPic,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildSilhouette(isDark: isDark),
                        ),
                      ),
                    )
                  : _buildSilhouette(isDark: isDark),
            ),

            // ── Bottom Name ─────────────────────────────────────
            Positioned(
              left: 14,
              right: 14,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    talent.name.isNotEmpty ? talent.name : 'Artist',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: nameColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSilhouette({bool isDark = false}) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person_rounded,
          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
          size: 36,
        ),
      ),
    );
  }
}