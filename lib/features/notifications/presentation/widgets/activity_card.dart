import 'package:aicc/core/constants/app_colors.dart';
import 'package:aicc/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/notification_model.dart';

class ActivityCard extends StatefulWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ActivityCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onDelete,
  });

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  // ── Helpers ────────────────────────────────────────────────────────────────

  Color _typeColor(String type) {
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
        return AppColors.primary;
    }
  }

  IconData _typeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'POST_LIKED':
        return Icons.favorite_rounded;
      case 'POST_COMMENTED':
        return Icons.chat_bubble_rounded;
      case 'POST_SHARED':
        return Icons.share_rounded;
      case 'FOLLOW':
      case 'SOCIAL':
        return Icons.person_add_alt_1_rounded;
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
        return Icons.notifications_rounded;
    }
  }

  String _actionText(String type) {
    switch (type.toUpperCase()) {
      case 'POST_LIKED':
        return 'liked your post';
      case 'POST_COMMENTED':
        return 'commented on your post';
      case 'POST_SHARED':
        return 'shared your post';
      case 'FOLLOW':
        return 'started following you';
      case 'AUDITION_APPLIED':
        return 'applied to your Casting call';
      case 'AUDITION_SHORTLISTED':
        return 'You have been shortlisted';
      case 'MESSAGE':
        return 'sent you a message';
      default:
        return widget.notification.message.isNotEmpty
            ? widget.notification.message
            : 'sent you a notification';
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

  void _handleNavigation(BuildContext context) {
    final n = widget.notification;
    final type = n.type.toUpperCase();
    final entity = n.entity;
    final entityType = entity?.type.toUpperCase() ?? '';
    final entityId = entity?.id ?? '';
    final actorId = n.actor?.id ?? '';

    if (type == 'FOLLOW' || type == 'SOCIAL') {
      if (actorId.isNotEmpty) {
        context.push(AppRoutes.exploreProfile, extra: actorId);
      }
      return;
    }

    if (type == 'MESSAGE' || entityType == 'CHAT') {
      final chatId = entityType == 'CHAT' ? entityId : entityId;
      if (chatId.isNotEmpty) {
        context.push(
          AppRoutes.chat,
          extra: {
            'chatId': chatId,
            'participantId': actorId,
          },
        );
      } else if (actorId.isNotEmpty) {
        context.push(AppRoutes.chat, extra: {'participantId': actorId});
      }
      return;
    }

    if (entity == null || entity.id.isEmpty) return;
    if (entityType == 'VIDEO' || entityType == 'PHOTO' || entityType == 'POST') {
      context.push(AppRoutes.watchVideo, extra: entity.id);
    } else if (entityType == 'AUDITION') {
      context.push(AppRoutes.auditionDetails, extra: entity.id);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkScaffold : Colors.white;
    final textPrimary = isDark ? AppColors.darkText : const Color(0xFF111827);
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : const Color(0xFF6B7280);
    final unreadBg = isDark
        ? AppColors.darkSurface.withValues(alpha: 0.6)
        : const Color(0xFFFFF8F0);

    final typeColor = _typeColor(widget.notification.type);
    final isUnread = !widget.notification.isRead;

    final actorPhoto = widget.notification.actor?.profilePhoto;
    final actorName = widget.notification.actor?.name ?? '';
    final entityThumb =
        widget.notification.metadata?['thumbnail'] as String? ??
            widget.notification.metadata?['image'] as String?;

    return Dismissible(
      key: Key(widget.notification.id),
      direction: DismissDirection.endToStart,
      // Do NOT auto-dismiss — just reveal the delete button
      confirmDismiss: (_) => Future.value(false),
      background: GestureDetector(
        onTap: () => widget.onDelete?.call(),
        child: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade300, Colors.red.shade700],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          widget.onTap?.call();
          _handleNavigation(context);
        },
        child: Container(
          color: isUnread ? unreadBg : bgColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Left: avatar with type badge ─────────────────────────────
              _buildAvatarStack(actorPhoto, actorName, typeColor),

              const SizedBox(width: 12),

              // ── Middle: rich inline text ──────────────────────────────────
              Expanded(
                child: _buildTextContent(
                  actorName: actorName,
                  actionText: _actionText(widget.notification.type),
                  timeText: _formatTime(widget.notification.createdAt),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  isUnread: isUnread,
                ),
              ),

              const SizedBox(width: 12),

              // ── Right: thumbnail or unread dot ────────────────────────────
              _buildRightSection(entityThumb, typeColor, isUnread),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sub-builders ───────────────────────────────────────────────────────────

  Widget _buildAvatarStack(String? photoUrl, String name, Color typeColor) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _circleAvatar(photoUrl, name, typeColor, radius: 24),
          Positioned(
            bottom: -2,
            right: -4,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: typeColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Icon(
                _typeIcon(widget.notification.type),
                size: 10,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleAvatar(String? photoUrl, String name, Color typeColor,
      {double radius = 22}) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(photoUrl),
        backgroundColor: typeColor.withValues(alpha: 0.12),
        onBackgroundImageError: (_, __) {},
      );
    }
    if (name.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: typeColor.withValues(alpha: 0.15),
        child: Text(
          name[0].toUpperCase(),
          style: TextStyle(
            color: typeColor,
            fontWeight: FontWeight.bold,
            fontSize: radius * 0.75,
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: typeColor.withValues(alpha: 0.12),
      child: Icon(_typeIcon(''), color: typeColor, size: radius * 0.9),
    );
  }

  Widget _buildTextContent({
    required String actorName,
    required String actionText,
    required String timeText,
    required Color textPrimary,
    required Color textSecondary,
    required bool isUnread,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              color: textPrimary,
              fontSize: 14,
              height: 1.4,
            ),
            children: [
              if (actorName.isNotEmpty) ...[
                TextSpan(
                  text: actorName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: ' '),
              ],
              TextSpan(
                text: actionText,
                style: TextStyle(
                  fontWeight: isUnread ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          timeText,
          style: TextStyle(
            color: textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildRightSection(String? thumbUrl, Color typeColor, bool isUnread) {
    if (thumbUrl != null && thumbUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          thumbUrl,
          width: 54,
          height: 54,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _unreadDot(typeColor, isUnread),
        ),
      );
    }
    return SizedBox(
      width: 54,
      child: isUnread
          ? Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: typeColor,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }

  Widget _unreadDot(Color typeColor, bool isUnread) {
    if (!isUnread) return const SizedBox(width: 54);
    return SizedBox(
      width: 54,
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: typeColor, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
