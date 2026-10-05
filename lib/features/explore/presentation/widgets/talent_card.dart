import 'package:aicc/core/api/api_endpoints.dart';
import 'package:aicc/features/artist_profile/presentation/providers/profile_provider.dart';
import 'package:aicc/features/explore/data/models/talent_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';

class TalentCard extends StatelessWidget {
  final TalentModel talent;

  const TalentCard({super.key, required this.talent});

  String _formatFollowers(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M followers';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k followers';
    }
    return '$count followers';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Dark card background matching the mockup
    final cardBg = isDark
        ? const Color(0xFF1C1C1E)
        : const Color(0xFFF5F5F5);
    final nameColor = isDark ? Colors.white : AppColors.lightText;
    final subtitleColor = isDark ? const Color(0xFF8A8A8E) : const Color(0xFF6B7280);

    final formattedPic = talent.pic.isNotEmpty
        ? ApiEndpoints.formatMediaUrl(talent.pic)
        : '';
    final hasValidNetworkPic = formattedPic.startsWith('http');

    // First card gets a filled follow button (amber), others get outlined
    final bool isFollowing = talent.following;

    return GestureDetector(
      onTap: () {
        if (talent.id.isNotEmpty) {
          context.push(AppRoutes.exploreProfile, extra: talent.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? const Color(0xFF2C2C2E)
                : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // ── Avatar ─────────────────────────────────────────────
            _buildAvatar(hasValidNetworkPic, formattedPic, isDark),

            const SizedBox(width: 14),

            // ── Name / Role / Followers ─────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    talent.name.isNotEmpty ? talent.name : 'Artist',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: nameColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    talent.category.isNotEmpty ? talent.category : 'Artist',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: subtitleColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _formatFollowers(talent.followers),
                    style: GoogleFonts.poppins(
                      color: subtitleColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ── Follow Button ───────────────────────────────────────
            _FollowButton(talentId: talent.id, talentName: talent.name),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(bool hasValidNetworkPic, String formattedPic, bool isDark) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: ClipOval(
        child: hasValidNetworkPic
            ? Image.network(
                formattedPic,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildSilhouette(isDark: isDark),
              )
            : _buildSilhouette(isDark: isDark),
      ),
    );
  }

  Widget _buildSilhouette({bool isDark = false}) {
    return Container(
      color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB),
      child: Center(
        child: Icon(
          Icons.person_rounded,
          color: isDark ? const Color(0xFF8A8A8E) : const Color(0xFF94A3B8),
          size: 34,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Follow Button — backed by ProfileProvider for global synchronization
// ──────────────────────────────────────────────────────────────────────────────
class _FollowButton extends StatelessWidget {
  final String talentId;
  final String talentName;

  const _FollowButton({required this.talentId, required this.talentName});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final isFollowing = profileProvider.isFollowing(talentId);
    final isFollowLoading = profileProvider.isFollowLoading(talentId);

    return GestureDetector(
      onTap: isFollowLoading || talentId.isEmpty
          ? null
          : () async {
              try {
                await profileProvider.toggleFollowUser(talentId, userName: talentName);
              } catch (_) {}
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isFollowing ? Colors.transparent : AppColors.primary,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        child: isFollowLoading
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  color: Colors.white,
                ),
              )
            : Text(
                isFollowing ? 'Following' : 'Follow',
                style: GoogleFonts.poppins(
                  color: isFollowing ? AppColors.primary : Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
      ),
    );
  }
}