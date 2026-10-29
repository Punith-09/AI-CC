import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/push_notification_payload.dart';
import '../../../../core/services/push_notification_service.dart';

/// In-app top banner used when the OS heads-up notification is unavailable
/// (permission denied) or as the designed foreground presentation.
class ForegroundNotificationHost extends StatefulWidget {
  final Widget child;

  const ForegroundNotificationHost({super.key, required this.child});

  @override
  State<ForegroundNotificationHost> createState() =>
      _ForegroundNotificationHostState();
}

class _ForegroundNotificationHostState extends State<ForegroundNotificationHost> {
  StreamSubscription<PushNotificationPayload>? _sub;
  OverlayEntry? _entry;
  String? _visibleKey;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _sub = PushNotificationService.instance.foregroundBanners.listen(_show);
  }

  @override
  void dispose() {
    _sub?.cancel();
    _hideTimer?.cancel();
    _entry?.remove();
    super.dispose();
  }

  void _show(PushNotificationPayload payload) {
    if (!mounted) return;
    if (_visibleKey == payload.dedupeKey) return;

    _hideTimer?.cancel();
    _entry?.remove();
    _entry = null;

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    _visibleKey = payload.dedupeKey;
    _entry = OverlayEntry(
      builder: (context) {
        final top = MediaQuery.paddingOf(context).top;
        return Positioned(
          top: top + 8,
          left: 12,
          right: 12,
          child: _BannerCard(
            payload: payload,
            onTap: () {
              _dismiss();
              PushNotificationService.instance.openPayload(payload);
            },
            onDismiss: _dismiss,
          ),
        );
      },
    );
    overlay.insert(_entry!);
    _hideTimer = Timer(const Duration(seconds: 5), _dismiss);
  }

  void _dismiss() {
    _hideTimer?.cancel();
    _entry?.remove();
    _entry = null;
    _visibleKey = null;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _BannerCard extends StatelessWidget {
  final PushNotificationPayload payload;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _BannerCard({
    required this.payload,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeColor = _typeColor(payload.type);
    final name = payload.actorName?.isNotEmpty == true
        ? payload.actorName!
        : payload.title;
    final message = payload.body.isNotEmpty ? payload.body : payload.title;

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onTap,
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! < -80) {
            onDismiss();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _Avatar(
                    url: payload.actorPhoto,
                    name: name,
                    color: typeColor,
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: typeColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Icon(
                        _typeIcon(payload.type),
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.25,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Just now',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onDismiss,
                icon: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type.toUpperCase()) {
      case 'POST_LIKED':
        return Colors.pinkAccent;
      case 'POST_COMMENTED':
        return const Color(0xFF4AD0FB);
      case 'COMMENT_LIKED':
        return Colors.deepPurpleAccent;
      case 'STORY_LIKED':
      case 'STORY_REPLIED':
        return Colors.purpleAccent;
      case 'FOLLOW':
      case 'NEW_FOLLOWER':
        return Colors.blue;
      case 'MESSAGE':
      case 'NEW_MESSAGE':
        return Colors.teal;
      case 'AUDITION':
      case 'AUDITION_APPLIED':
      case 'AUDITION_SHORTLISTED':
        return Colors.orange;
      case 'AUDITION_CANCELLED':
      case 'AUDITION_UPDATED':
        return Colors.deepOrange;
      case 'APPLICATION_SHORTLISTED':
      case 'APPLICATION_ACCEPTED':
        return Colors.green;
      case 'APPLICATION_REJECTED':
        return Colors.redAccent;
      case 'APPLICATION_STATUS_UPDATED':
        return Colors.amber;
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
      case 'COMMENT_LIKED':
        return Icons.thumb_up_alt_rounded;
      case 'STORY_LIKED':
        return Icons.favorite_border_rounded;
      case 'STORY_REPLIED':
        return Icons.reply_rounded;
      case 'FOLLOW':
      case 'NEW_FOLLOWER':
        return Icons.person_add_alt_1_rounded;
      case 'MESSAGE':
      case 'NEW_MESSAGE':
        return Icons.chat_bubble_outline;
      case 'AUDITION':
      case 'AUDITION_APPLIED':
      case 'AUDITION_SHORTLISTED':
        return Icons.movie_creation_outlined;
      case 'AUDITION_CANCELLED':
      case 'AUDITION_UPDATED':
        return Icons.event_busy_rounded;
      case 'APPLICATION_SHORTLISTED':
      case 'APPLICATION_ACCEPTED':
        return Icons.check_circle_outline_rounded;
      case 'APPLICATION_REJECTED':
        return Icons.cancel_outlined;
      case 'APPLICATION_STATUS_UPDATED':
        return Icons.update_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  final String name;
  final Color color;

  const _Avatar({
    required this.url,
    required this.name,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (url != null && url!.isNotEmpty) {
      return CircleAvatar(
        radius: 22,
        backgroundColor: color.withValues(alpha: 0.12),
        backgroundImage: NetworkImage(url!),
        onBackgroundImageError: (_, _) {},
      );
    }
    return CircleAvatar(
      radius: 22,
      backgroundColor: color.withValues(alpha: 0.15),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'T',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
