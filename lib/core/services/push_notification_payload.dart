import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../../features/notifications/data/models/notification_model.dart';

/// Normalized FCM / local-notification payload.
///
/// Field names are taken from the in-app notification REST model
/// ([NotificationModel]) plus common FCM `data` aliases. Unknown keys are
/// kept in [rawData] and never invented.
class PushNotificationPayload {
  final String id;
  final String title;
  final String body;
  final String type;
  final String? entityType;
  final String? entityId;
  final String? actorId;
  final String? actorName;
  final String? actorPhoto;
  final String? chatId;
  final DateTime receivedAt;
  final Map<String, String> rawData;

  const PushNotificationPayload({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.receivedAt,
    this.entityType,
    this.entityId,
    this.actorId,
    this.actorName,
    this.actorPhoto,
    this.chatId,
    this.rawData = const {},
  });

  String get dedupeKey {
    if (id.isNotEmpty) return id;
    return '$type|$entityId|$actorId|$title|$body';
  }

  factory PushNotificationPayload.fromRemoteMessage(RemoteMessage message) {
    final data = <String, String>{};
    message.data.forEach((key, value) {
      data[key] = value.toString();
    });

    final nested = _decodeJsonMap(data['payload'] ?? data['data']);
    if (nested != null) {
      nested.forEach((key, value) {
        data.putIfAbsent(key, () => value.toString());
      });
    }

    final actorMap = _decodeJsonMap(data['actor']);
    final entityMap = _decodeJsonMap(data['entity']);

    final actorId = _firstNonEmpty([
      data['actorId'],
      data['actor_id'],
      data['senderId'],
      data['sender_id'],
      data['userId'],
      data['user_id'],
      actorMap?['id']?.toString(),
      actorMap?['_id']?.toString(),
    ]);
    final actorName = _firstNonEmpty([
      data['actorName'],
      data['actor_name'],
      data['senderName'],
      data['sender_name'],
      actorMap?['name']?.toString(),
      actorMap?['fullName']?.toString(),
    ]);
    final actorPhoto = _firstNonEmpty([
      data['actorPhoto'],
      data['actor_photo'],
      data['profilePhoto'],
      data['senderPhoto'],
      actorMap?['profilePhoto']?.toString(),
      actorMap?['avatar']?.toString(),
    ]);

    final entityType = _firstNonEmpty([
      data['entityType'],
      data['entity_type'],
      entityMap?['type']?.toString(),
    ]);
    final entityId = _firstNonEmpty([
      data['entityId'],
      data['entity_id'],
      data['postId'],
      data['post_id'],
      data['videoId'],
      data['photoId'],
      data['auditionId'],
      data['audition_id'],
      entityMap?['id']?.toString(),
      entityMap?['_id']?.toString(),
    ]);

    final chatId = _firstNonEmpty([
      data['chatId'],
      data['chat_id'],
      if ((entityType ?? '').toUpperCase() == 'CHAT') entityId,
    ]);

    final type = _firstNonEmpty([
          data['type'],
          data['notificationType'],
          entityType,
        ]) ??
        'general';

    final title = _firstNonEmpty([
          message.notification?.title,
          data['title'],
          actorName,
        ]) ??
        'TreeKo';

    final body = _firstNonEmpty([
          message.notification?.body,
          data['body'],
          data['text'],
          data['message'],
        ]) ??
        '';

    final id = _firstNonEmpty([
          data['_id'],
          data['id'],
          data['notificationId'],
          data['notification_id'],
          message.messageId,
        ]) ??
        '';

    return PushNotificationPayload(
      id: id,
      title: title,
      body: body,
      type: type,
      entityType: entityType,
      entityId: entityId,
      actorId: actorId,
      actorName: actorName,
      actorPhoto: actorPhoto,
      chatId: chatId,
      receivedAt: message.sentTime ?? DateTime.now(),
      rawData: data,
    );
  }

  factory PushNotificationPayload.fromMap(Map<String, dynamic> map) {
    final data = <String, String>{};
    map.forEach((key, value) {
      if (value != null) data[key] = value.toString();
    });

    DateTime receivedAt = DateTime.now();
    final rawTime = data['time'] ?? data['createdAt'] ?? data['receivedAt'];
    if (rawTime != null) {
      receivedAt = DateTime.tryParse(rawTime) ?? DateTime.now();
    }

    return PushNotificationPayload(
      id: data['id'] ?? data['_id'] ?? data['notificationId'] ?? '',
      title: data['title'] ?? 'TreeKo',
      body: data['body'] ?? data['text'] ?? data['message'] ?? '',
      type: data['type'] ?? 'general',
      entityType: data['entityType'] ?? data['entity_type'],
      entityId: data['entityId'] ?? data['entity_id'],
      actorId: data['actorId'] ?? data['actor_id'] ?? data['userId'],
      actorName: data['actorName'] ?? data['actor_name'],
      actorPhoto: data['actorPhoto'] ?? data['actor_photo'] ?? data['profilePhoto'],
      chatId: data['chatId'] ?? data['chat_id'],
      receivedAt: receivedAt,
      rawData: data,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type,
        'entityType': entityType,
        'entityId': entityId,
        'actorId': actorId,
        'actorName': actorName,
        'actorPhoto': actorPhoto,
        'chatId': chatId,
        'receivedAt': receivedAt.toIso8601String(),
      };

  String toPayloadString() => jsonEncode(toMap());

  static PushNotificationPayload? tryParse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return PushNotificationPayload.fromMap(
          Map<String, dynamic>.from(decoded),
        );
      }
    } catch (_) {}
    return null;
  }

  NotificationModel toNotificationModel() {
    return NotificationModel(
      id: id,
      title: title,
      message: body,
      type: type,
      isRead: false,
      createdAt: receivedAt,
      actor: actorId != null || actorName != null
          ? NotificationActor(
              id: actorId ?? '',
              name: actorName ?? 'Someone',
              profilePhoto: actorPhoto,
            )
          : null,
      entity: entityId != null
          ? NotificationEntity(
              type: entityType ?? '',
              id: entityId!,
            )
          : null,
    );
  }

  static Map<String, dynamic>? _decodeJsonMap(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final trimmed = raw.trim();
    if (!trimmed.startsWith('{')) return null;
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}
    return null;
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }
}
