import 'package:aicc/core/constants/app_colors.dart';
import 'package:aicc/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    switch (type.toUpperCase()) {
      case 'POST_LIKED':
        return Icons.favorite_rounded;
      case 'POST_COMMENTED':
        return Icons.chat_bubble_rounded;
      case 'POST_SHARED':
        return Icons.share_rounded;
      case 'FOLLOW':
      case 'SOCIAL':
        return Icons.person_add_alt_1_outlined;
      case 'MESSAGE':
        return Icons.chat_bubble_outline;
      case 'AUDITION':
      case 'AUDITION_APPLIED':
      case 'AUDITION_SHORTLISTED':
        return Icons.movie_creation_outlined;
      case 'MATCH':
      case 'AI_MATCH':
        return Icons.auto_awesome;
      case 'PAYMENT':
        return Icons.payment_outlined;
      case 'VERIFICATION':
        return Icons.verified_user_outlined;
      default:
        return Icons.notifications_none_outlined;
    }
  }

  Color _colorForType(String type) {
    switch (type.toUpperCase()) {
      case 'POST_LIKED':
        return Colors.pinkAccent;
      case 'POST_COMMENTED':
        return const Color(0xFF4AD0FB);
      case 'POST_SHARED':
        return Colors.deepPurpleAccent;
      case 'FOLLOW':
      case 'SOCIAL':
        return Colors.blue;
      case 'MESSAGE':
        return Colors.teal;
      case 'AUDITION':
      case 'AUDITION_APPLIED':
      case 'AUDITION_SHORTLISTED':
        return Colors.orange;
      case 'MATCH':
      case 'AI_MATCH':
        return Colors.amber;
      case 'PAYMENT':
        return Colors.green;
      case 'VERIFICATION':
        return Colors.deepPurple;
      default:
        return const Color(0xFF4AD0FB);
    }
  }

  String _badgeLabel(String type) {
    switch (type.toUpperCase()) {
      case 'POST_LIKED':
        return 'LIKED';
      case 'POST_COMMENTED':
        return 'COMMENTED';
      case 'POST_SHARED':
        return 'SHARED';
      case 'MATCH':
      case 'AI_MATCH':
        return 'AI MATCH';
      case 'AUDITION_APPLIED':
        return 'APPLICATION';
      case 'AUDITION_SHORTLISTED':
        return 'SHORTLISTED';
      case 'VERIFICATION':
        return 'VERIFICATION';
      case 'FOLLOW':
      case 'SOCIAL':
        return 'SOCIAL';
      case 'MESSAGE':
        return 'MESSAGE';
      case 'AUDITION':
        return 'AUDITION';
      case 'PAYMENT':
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

  /// Navigate to the relevant post/entity when the card is tapped
  void _handleNavigation(BuildContext context) {
    final entity = notification.entity;
    if (entity == null || entity.id.isEmpty) return;

    final entityType = entity.type.toUpperCase();
    if (entityType == 'VIDEO' || entityType == 'PHOTO' || entityType == 'POST') {
      // Navigate to watch/post detail screen, passing entity id as extra
      context.push(AppRoutes.watchVideo, extra: entity.id);
    } else if (entityType == 'AUDITION') {
      context.push(AppRoutes.auditionDetails, extra: entity.id);
    }
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

    // Actor avatar or icon
    final actorPhoto = notification.actor?.profilePhoto;
    final actorName = notification.actor?.name ?? '';

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
        onTap: () {
          onTap?.call();
          _handleNavigation(context);
        },
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
                      // Actor avatar (profile photo) or fallback icon
                      _buildAvatar(actorPhoto, actorName, typeColor),
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
                                    notification.displayTitle,
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
                            // Rich description: "user15 liked your post."
                            Text(
                              notification.displayText,
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

  Widget _buildAvatar(String? photoUrl, String name, Color typeColor) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 23,
        backgroundImage: NetworkImage(photoUrl),
        backgroundColor: typeColor.withValues(alpha: 0.12),
        onBackgroundImageError: (_, __) {},
      );
    }
    // Fallback: initials or icon
    if (name.isNotEmpty) {
      return CircleAvatar(
        radius: 23,
        backgroundColor: typeColor.withValues(alpha: 0.15),
        child: Text(
          name[0].toUpperCase(),
          style: TextStyle(
            color: typeColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      );
    }
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _iconForType(''),
        color: typeColor,
        size: 22,
      ),
    );
  }
}
