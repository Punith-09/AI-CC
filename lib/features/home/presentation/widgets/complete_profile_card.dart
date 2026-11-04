import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../artist_profile/presentation/providers/profile_provider.dart';
import '../providers/home_feed_provider.dart';

class CompleteProfileCard extends StatelessWidget {
  const CompleteProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final feedProvider = context.watch<HomeFeedProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final completion = profileProvider.completion;
    final currentProfile = profileProvider.currentProfile;
    final myUserId = LocalStorage.instance.getUserId();

    // ── Step 1: Share a short audition video (50% max) ───────
    final hasAuditionVideo = (currentProfile?.portfolio ?? []).any((m) => m.isVideo) ||
        feedProvider.videoPosts.any((p) => p.creatorId == myUserId) ||
        (completion?.completedFields ?? []).contains('video') ||
        (completion?.completedFields ?? []).contains('portfolio');

    // ── Step 2: Complete your biodata (50% max) ──────────────
    // The API returns the completion percentage for biodata steps (0 - 100%)
    final int biodataApiPercent = completion?.percentage ?? 0;
    final bool isBiodataFullyComplete =
        profileProvider.isProfileCompleted || biodataApiPercent >= 100;

    // ── Proportional Progress Ratio (50% / 50%) ──────────────
    // Audition video gives 50% upon upload
    final int videoContribution = hasAuditionVideo ? 50 : 0;

    // Biodata gives proportional progress up to 50% based on the API percentage
    final int biodataContribution = isBiodataFullyComplete
        ? 50
        : ((biodataApiPercent / 100.0) * 50).round();

    final int totalPercentage =
        (videoContribution + biodataContribution).clamp(0, 100);

    int pendingCount = 0;
    if (!hasAuditionVideo) pendingCount++;
    if (!isBiodataFullyComplete) pendingCount++;

    // If both are completed (100%), hide the card
    if (totalPercentage >= 100 || pendingCount == 0) {
      return const SizedBox.shrink();
    }

    final double progress = (totalPercentage / 100.0).clamp(0.0, 1.0);

    // Color palette adapting to present app
    final cardBg = isDark
        ? const Color(0xFF18181B)
        : const Color(0xFFFFF8F0); // subtle warm amber/orange tint
    final borderColor = isDark
        ? AppColors.primary.withValues(alpha: 0.3)
        : AppColors.primary.withValues(alpha: 0.22);
    final titleColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subtextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header Row (Title, Subtitle & Circular Gauge) ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Complete below steps so that profile will be 100% completed.',
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.35,
                        color: subtextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // ── Circular Progress Ring ──
              SizedBox(
                width: 58,
                height: 58,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 58,
                      height: 58,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 5,
                        strokeCap: StrokeCap.round,
                        backgroundColor: isDark
                            ? Colors.white12
                            : AppColors.primary.withValues(alpha: 0.16),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$totalPercentage%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                          ),
                        ),
                        Text(
                          '$pendingCount pending',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w500,
                            color: subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Step 1: Share a short audition video (50%) ─────
          _StepItem(
            stepNumber: 1,
            icon: Icons.videocam_outlined,
            isCompleted: hasAuditionVideo,
            richText: _buildRichText(
              prefix: 'Share a short ',
              highlight: 'audition video',
              suffix: '.',
              isDark: isDark,
            ),
            buttonLabel: 'Record >',
            onTap: () async {
              final result = await context.push(AppRoutes.uploadVideo);
              if (result == true && context.mounted) {
                context.read<ProfileProvider>().fetchMyProfile(silent: true);
                context.read<ProfileProvider>().fetchProfileCompletion();
                context.read<HomeFeedProvider>().fetchFeed();
              }
            },
          ),

          // ── Step 2: Complete your biodata (50%) ────────────
          _StepItem(
            stepNumber: 2,
            icon: Icons.description_outlined,
            isCompleted: isBiodataFullyComplete,
            richText: _buildRichText(
              prefix: 'Complete your ',
              highlight: 'biodata',
              suffix: biodataApiPercent > 0 && !isBiodataFullyComplete
                  ? ' ($biodataApiPercent%)'
                  : '.',
              isDark: isDark,
            ),
            buttonLabel: biodataApiPercent > 0 ? 'Continue >' : 'Update >',
            onTap: () async {
              // Navigates directly to the 5-step profile completion workflow
              await context.push(AppRoutes.completeProfile);
              if (context.mounted) {
                context.read<ProfileProvider>().fetchMyProfile(silent: true);
                context.read<ProfileProvider>().fetchProfileCompletion();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRichText({
    required String prefix,
    required String highlight,
    required String suffix,
    required bool isDark,
  }) {
    final regularColor = isDark ? Colors.white70 : const Color(0xFF334155);
    final boldColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 13,
          color: regularColor,
          fontFamily: 'Inter',
        ),
        children: [
          TextSpan(text: prefix),
          TextSpan(
            text: highlight,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: boldColor,
            ),
          ),
          TextSpan(text: suffix),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final int stepNumber;
  final IconData icon;
  final Widget richText;
  final String buttonLabel;
  final bool isCompleted;
  final VoidCallback onTap;

  const _StepItem({
    required this.stepNumber,
    required this.icon,
    required this.richText,
    required this.buttonLabel,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final rowBg = isDark ? AppColors.darkSurface : Colors.white;
    final rowBorder = isDark ? AppColors.darkBorder : const Color(0xFFF1F5F9);
    final numberColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: rowBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: rowBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Step Number
          SizedBox(
            width: 18,
            child: Text(
              '$stepNumber',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: numberColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),

          // 2. Icon Circle
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 19,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),

          // 3. Description
          Expanded(child: richText),

          const SizedBox(width: 8),

          // 4. Action Button or Done Badge
          if (isCompleted)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.green, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    buttonLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
