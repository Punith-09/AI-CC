import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const NotificationCard({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final cardBorder = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
    final titleColor = isDark ? AppColors.darkText : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final timeColor =
        isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8);
    final chevronColor =
        isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8);

    final isUnread = !notification.isRead;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isUnread
              ? notification.badgeColor.withValues(alpha: 0.5)
              : cardBorder,
          width: isUnread ? 1.5 : 1,
        ),
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
          // Unread accent bar
          if (isUnread)
            Container(
              width: 4,
              height: 100,
              decoration: BoxDecoration(
                color: notification.badgeColor,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: notification.badgeColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      notification.icon,
                      color: notification.badgeColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                notification.title.isNotEmpty
                                    ? notification.title
                                    : _labelFromType(notification.type),
                                style: TextStyle(
                                  color: titleColor,
                                  fontWeight: isUnread
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              notification.timeAgo,
                              style: TextStyle(
                                color: timeColor,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        if (notification.message.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(
                            notification.message,
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 13,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 10),
                        // Badge pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: notification.badgeColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            notification.badgeLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: chevronColor,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _labelFromType(String type) {
    switch (type.toLowerCase()) {
      case 'follow':
        return 'New Follower';
      case 'like':
        return 'Someone liked your post';
      case 'comment':
        return 'New Comment';
      case 'match':
      case 'ai_match':
        return 'AI Match Found';
      case 'application':
        return 'Application Update';
      case 'verification':
        return 'Profile Verified';
      case 'message':
        return 'New Message';
      case 'audition':
        return 'Audition Update';
      default:
        return 'Notification';
    }
  }
}
