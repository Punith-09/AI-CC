class NotificationActor {
  final String id;
  final String name;
  final String? profilePhoto;

  const NotificationActor({
    required this.id,
    required this.name,
    this.profilePhoto,
  });

  factory NotificationActor.fromJson(Map<String, dynamic> json) {
    return NotificationActor(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Someone',
      profilePhoto: json['profilePhoto'] as String?,
    );
  }
}

class NotificationEntity {
  final String type; // e.g. "VIDEO", "PHOTO", "AUDITION"
  final String id;

  const NotificationEntity({required this.type, required this.id});

  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      type: json['type'] as String? ?? '',
      id: json['id'] as String? ?? '',
    );
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message; // raw text from API ("Someone liked your post.")
  final String type;    // e.g. POST_LIKED, POST_COMMENTED, FOLLOW
  final bool isRead;
  final DateTime createdAt;
  final NotificationActor? actor;
  final NotificationEntity? entity;
  final Map<String, dynamic>? metadata;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.actor,
    this.entity,
    this.metadata,
  });

  /// Human-friendly text: "user15 liked your post" instead of generic "Someone liked your post."
  String get displayText {
    final name = actor?.name ?? 'Someone';
    switch (type.toUpperCase()) {
      case 'POST_LIKED':
        return '$name liked your post.';
      case 'POST_COMMENTED':
        return '$name commented on your post.';
      case 'POST_SHARED':
        return '$name shared your post.';
      case 'FOLLOW':
        return '$name started following you.';
      case 'AUDITION_APPLIED':
        return '$name applied to your audition.';
      case 'AUDITION_SHORTLISTED':
        return 'You have been shortlisted for an audition.';
      case 'MESSAGE':
        return '$name sent you a message.';
      default:
        return message.isNotEmpty ? message : '$name sent you a notification.';
    }
  }

  /// Title derived from type (replaces generic API title)
  String get displayTitle {
    switch (type.toUpperCase()) {
      case 'POST_LIKED':
        return 'New Like';
      case 'POST_COMMENTED':
        return 'New Comment';
      case 'POST_SHARED':
        return 'New Share';
      case 'FOLLOW':
        return 'New Follower';
      case 'AUDITION_APPLIED':
        return 'New Application';
      case 'AUDITION_SHORTLISTED':
        return 'Shortlisted!';
      case 'MESSAGE':
        return 'New Message';
      default:
        return title.isNotEmpty ? title : 'Notification';
    }
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Parse actor
    NotificationActor? actor;
    if (json['actor'] is Map<String, dynamic>) {
      actor = NotificationActor.fromJson(json['actor'] as Map<String, dynamic>);
    }

    // Parse entity
    NotificationEntity? entity;
    if (json['entity'] is Map<String, dynamic>) {
      entity = NotificationEntity.fromJson(json['entity'] as Map<String, dynamic>);
    }

    // Parse date — API uses "time" field; fallback to "createdAt"
    DateTime createdAt = DateTime.now();
    final rawTime = json['time'] ?? json['createdAt'];
    if (rawTime != null) {
      createdAt = DateTime.tryParse(rawTime.toString()) ?? DateTime.now();
    }

    return NotificationModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['text'] as String? ?? json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'general',
      isRead: json['read'] as bool? ?? json['isRead'] as bool? ?? false,
      createdAt: createdAt,
      actor: actor,
      entity: entity,
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
      actor: actor,
      entity: entity,
      metadata: metadata,
    );
  }
}
