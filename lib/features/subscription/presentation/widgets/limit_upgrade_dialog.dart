import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../providers/subscription_provider.dart';

class LimitUpgradeDialog extends StatelessWidget {
  final LimitType type;
  final String? customMessage;

  const LimitUpgradeDialog({
    super.key,
    required this.type,
    this.customMessage,
  });

  static Future<void> show(
    BuildContext context, {
    required LimitType type,
    String? customMessage,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => LimitUpgradeDialog(
        type: type,
        customMessage: customMessage,
      ),
    );
  }

  static void showSnackBar(
    BuildContext context, {
    required LimitType type,
    String? customMessage,
  }) {
    final subProvider = context.read<SubscriptionProvider>();
    final plan = subProvider.planLabel;
    String text;

    switch (type) {
      case LimitType.like:
        text = customMessage ??
            'Daily like limit reached (${subProvider.limits.likesPerDay}/day on $plan).';
        break;
      case LimitType.comment:
        text = customMessage ??
            'Daily comment limit reached (${subProvider.limits.commentsPerDay}/day on $plan).';
        break;
      case LimitType.auditionApplication:
        text = customMessage ??
            'Daily audition application limit reached (${subProvider.limits.auditionApplicationsPerDay}/day on $plan).';
        break;
      case LimitType.message:
        text = customMessage ?? 'Daily message limit reached on $plan.';
        break;
      case LimitType.profileView:
        text = customMessage ?? 'Daily profile view limit reached on $plan.';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFF59E0B), width: 1),
        ),
        action: SnackBarAction(
          label: 'UPGRADE',
          textColor: const Color(0xFF1CC8FF),
          onPressed: () {
            context.push(AppRoutes.subscription);
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subProvider = context.watch<SubscriptionProvider>();
    final planLabel = subProvider.planLabel;
    final isProMax = subProvider.activePlan.contains('max');

    String title;
    IconData icon;
    String description;
    String limitValue;

    switch (type) {
      case LimitType.auditionApplication:
        title = 'Audition Limit Reached';
        icon = Icons.movie_filter_rounded;
        limitValue = '${subProvider.limits.auditionApplicationsPerDay} applications/day';
        description = customMessage ??
            (isProMax
                ? 'You have reached today\'s limit of $limitValue on your $planLabel plan. Limits reset tomorrow!'
                : 'You have used all $limitValue available on your $planLabel plan today. Upgrade to Pro or Pro Max to apply for up to 50 auditions per day!');
        break;
      case LimitType.like:
        title = 'Daily Like Limit Reached';
        icon = Icons.favorite_rounded;
        limitValue = '${subProvider.limits.likesPerDay} likes/day';
        description = customMessage ??
            (isProMax
                ? 'You have reached today\'s limit of $limitValue on your $planLabel plan. Limits reset tomorrow!'
                : 'You have used all $limitValue on your $planLabel plan today. Upgrade to get up to 500 likes daily and amplify your interactions!');
        break;
      case LimitType.comment:
        title = 'Daily Comment Limit Reached';
        icon = Icons.chat_bubble_rounded;
        limitValue = '${subProvider.limits.commentsPerDay} comments/day';
        description = customMessage ??
            (isProMax
                ? 'You have reached today\'s limit of $limitValue on your $planLabel plan. Limits reset tomorrow!'
                : 'You have used all $limitValue on your $planLabel plan today. Upgrade to unlock up to 100 daily comments and connect with creators!');
        break;
      case LimitType.message:
        title = 'Message Limit Reached';
        icon = Icons.send_rounded;
        limitValue = '${subProvider.limits.messagesPerDay} messages/day';
        description = customMessage ??
            'You have reached your daily message limit ($limitValue) on $planLabel. Upgrade to connect with more directors.';
        break;
      case LimitType.profileView:
        title = 'Profile Views Limit Reached';
        icon = Icons.visibility_rounded;
        limitValue = '${subProvider.limits.profileViewsPerDay} views/day';
        description = customMessage ??
            'You have reached your daily profile view limit ($limitValue) on $planLabel. Upgrade to view more profiles.';
        break;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? AppColors.darkCard : Colors.white;
    final titleColor = isDark ? AppColors.darkText : AppColors.lightText;
    final descColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final badgeBg = isDark ? AppColors.darkSurface : const Color(0xFFFEF3C7);
    final badgeTextColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: dialogBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
              blurRadius: 30,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: isDark ? Colors.black87 : Colors.black.withValues(alpha: 0.08),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with glowing badge
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),

            // Plan badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Text(
                'Current Plan: $planLabel',
                style: TextStyle(
                  color: badgeTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: titleColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 10),

            // Description
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: descColor,
                fontSize: 13.5,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),

            // Upgrade Button (if not already Pro Max)
            if (!isProMax)
              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1CC8FF), Color(0xFF0077B6)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1CC8FF).withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push(AppRoutes.subscription);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'UPGRADE PLAN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (!isProMax) const SizedBox(height: 10),

            // Dismiss Button
            SizedBox(
              width: double.infinity,
              height: 42,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  isProMax ? 'OK, GOT IT' : 'MAYBE LATER',
                  style: TextStyle(
                    color: isProMax ? const Color(0xFF1CC8FF) : const Color(0xFF94A3B8),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
