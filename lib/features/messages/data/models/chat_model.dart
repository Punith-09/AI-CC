import 'package:flutter/foundation.dart';

@immutable
class ChatModel {
  final String id;
  final String participantId;
  final String participantName;
  final String participantAvatar;
  final String participantRole;
  final String lastMessage;
  final String lastMessageAt;
  final int unreadCount;
  final bool isOnline;

  const ChatModel({
    required this.id,
    required this.participantId,
    this.participantName = '',
    this.participantAvatar = '',
    this.participantRole = '',
    this.lastMessage = '',
    this.lastMessageAt = '',
    this.unreadCount = 0,
    this.isOnline = false,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    // The participant can be nested under "otherParticipant", "participant",
    // "recipient", or "user" depending on backend shape.
    final dynamic rawParticipant = json['otherParticipant'] ??
        json['participant'] ??
        json['recipient'] ??
        json['user'];

    String participantId = '';
    String participantName = '';
    String participantAvatar = '';
    String participantRole = '';

    if (rawParticipant is Map<String, dynamic>) {
      participantId = _s(
        rawParticipant['id'] ?? rawParticipant['_id'],
      );
      participantName = _s(
        rawParticipant['name'] ??
            rawParticipant['fullName'] ??
            rawParticipant['username'],
      );
      participantAvatar = _s(
        rawParticipant['avatar'] ??
            rawParticipant['profileImage'] ??
            rawParticipant['photo'],
      );
      participantRole = _s(
        rawParticipant['role'] ?? rawParticipant['type'],
      );
    }

    // Fallback if not nested
    if (participantId.isEmpty) {
      participantId = _s(json['participantId'] ?? json['userId']);
    }
    if (participantName.isEmpty) {
      participantName = _s(json['participantName'] ?? json['name']);
    }

    // Last message
    final dynamic rawLastMsg = json['lastMessage'];
    String lastMessage = '';
    if (rawLastMsg is Map<String, dynamic>) {
      lastMessage = _s(rawLastMsg['content'] ?? rawLastMsg['text']);
    } else {
      lastMessage = _s(rawLastMsg ?? json['last_message']);
    }

    return ChatModel(
      id: _s(json['id'] ?? json['_id'] ?? json['chatId']),
      participantId: participantId,
      participantName: participantName,
      participantAvatar: participantAvatar,
      participantRole: participantRole,
      lastMessage: lastMessage,
      lastMessageAt: _s(
        json['lastMessageAt'] ??
            json['updatedAt'] ??
            json['createdAt'],
      ),
      unreadCount: _int(json['unreadCount'] ?? json['unread']),
      isOnline: _bool(json['isOnline'] ?? json['online']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'participantId': participantId,
        'participantName': participantName,
        'participantAvatar': participantAvatar,
        'participantRole': participantRole,
        'lastMessage': lastMessage,
        'lastMessageAt': lastMessageAt,
        'unreadCount': unreadCount,
        'isOnline': isOnline,
      };

  static String _s(dynamic v) => v?.toString() ?? '';

  static int _int(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static bool _bool(dynamic v) {
    if (v is bool) return v;
    if (v is String) return v.toLowerCase() == 'true';
    return false;
  }
}
