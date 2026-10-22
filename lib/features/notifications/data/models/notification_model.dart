import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String createdAt;
  final Map<String, dynamic>? metadata;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.metadata,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? json['body']?.toString() ?? '',
      type: json['type']?.toString() ?? 'general',
      isRead: json['isRead'] as bool? ?? json['read'] as bool? ?? false,
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString() ?? '',
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      metadata: metadata,
    );
  }

  /// Returns a human-readable relative time string.
  String get timeAgo {
    if (createdAt.isEmpty) return '';
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inSeconds < 60) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${(diff.inDays / 7).floor()}w ago';
    } catch (_) {
      return '';
    }
  }

  /// Maps notification type to an icon.
  IconData get icon {
    switch (type.toLowerCase()) {
      case 'follow':
        return Icons.person_add_rounded;
      case 'like':
        return Icons.favorite_rounded;
      case 'comment':
        return Icons.comment_rounded;
      case 'match':
      case 'ai_match':
        return Icons.auto_awesome_rounded;
      case 'application':
        return Icons.work_rounded;
      case 'verification':
        return Icons.verified_rounded;
      case 'message':
        return Icons.message_rounded;
      case 'audition':
        return Icons.movie_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  /// Maps notification type to a badge colour.
  Color get badgeColor {
    switch (type.toLowerCase()) {
      case 'follow':
        return const Color(0xFF6366F1);
      case 'like':
        return const Color(0xFFEC4899);
      case 'comment':
        return const Color(0xFF3B82F6);
      case 'match':
      case 'ai_match':
        return const Color(0xFFF59E0B);
      case 'application':
        return const Color(0xFF10B981);
      case 'verification':
        return const Color(0xFF8B5CF6);
      case 'message':
        return const Color(0xFF06B6D4);
      case 'audition':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }

  String get badgeLabel {
    switch (type.toLowerCase()) {
      case 'follow':
        return 'FOLLOW';
      case 'like':
        return 'LIKE';
      case 'comment':
        return 'COMMENT';
      case 'match':
      case 'ai_match':
        return 'AI MATCH';
      case 'application':
        return 'APPLICATION';
      case 'verification':
        return 'VERIFIED';
      case 'message':
        return 'MESSAGE';
      case 'audition':
        return 'AUDITION';
      default:
        return type.toUpperCase();
    }
  }
}
