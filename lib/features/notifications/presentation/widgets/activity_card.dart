import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';

class ActivityCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ActivityCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onDelete,
  });

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'match':
      case 'ai_match':
        return Icons.auto_awesome;
      case 'application':
        return Icons.work_outline;
      case 'verification':
        return Icons.verified_user_outlined;
      case 'follow':
      case 'social':
        return Icons.person_add_alt_1_outlined;
      case 'message':
        return Icons.chat_bubble_outline;
      case 'audition':
        return Icons.movie_creation_outlined;
      case 'payment':
        return Icons.payment_outlined;
      default:
        return Icons.notifications_none_outlined;
    }
  }

  Color _colorForType(String type) {
    switch (type.toLowerCase()) {
      case 'match':
      case 'ai_match':
        return Colors.amber;
      case 'application':
        return Colors.pink;
      case 'verification':
        return Colors.deepPurple;
      case 'follow':
      case 'social':
        return Colors.blue;
      case 'message':
        return Colors.teal;
      case 'audition':
        return Colors.orange;
      case 'payment':
        return Colors.green;
      default:
        return const Color(0xFF4AD0FB);
    }
  }

  String _badgeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'match':
      case 'ai_match':
        return 'AI MATCH';
      case 'application':
        return 'APPLICATION';
      case 'verification':
        return 'VERIFICATION';
      case 'follow':
      case 'social':
        return 'SOCIAL';
      case 'message':
        return 'MESSAGE';
      case 'audition':
        return 'AUDITION';
      case 'payment':
        return 'PAYMENT';
      default:
        return type.toUpperCase().isNotEmpty ? type.toUpperCase() : 'NOTIFICATION';
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

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

    final typeColor = _colorForType(notification.type);
    final isHighlight = !notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 26),
      ),
      confirmDismiss: (_) async {
        onDelete?.call();
        return true;
      },
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isHighlight ? typeColor.withValues(alpha: 0.4) : cardBorder,
              width: isHighlight ? 1.5 : 1,
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
              if (isHighlight)
                Container(
                  width: 4,
                  height: 110,
                  decoration: BoxDecoration(
                    color: typeColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _iconForType(notification.type),
                          color: typeColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    notification.title,
                                    style: TextStyle(
                                      color: titleColor,
                                      fontWeight: isHighlight
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatTime(notification.createdAt),
                                  style: TextStyle(
                                    color: timeColor,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification.message,
                              style: TextStyle(
                                color: subtitleColor,
                                height: 1.4,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: typeColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _badgeLabel(notification.type),
                                    style: TextStyle(
                                      color: typeColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                if (isHighlight) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: typeColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right, color: chevronColor, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
