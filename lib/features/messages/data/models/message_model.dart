import 'package:flutter/foundation.dart';

@immutable
class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final String createdAt;
  final bool isMe;
  final bool isRead;

  const MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.isMe = false,
    this.isRead = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    final senderRaw = json['sender'];
    final senderId = _s(
      json['senderId'] ??
          (senderRaw is Map ? senderRaw['id'] ?? senderRaw['_id'] : (senderRaw != 'me' ? senderRaw : '')),
    );
    final isMeFlag = json['isMe'] == true ||
        senderRaw == 'me' ||
        (currentUserId != null && currentUserId.isNotEmpty && senderId == currentUserId);

    return MessageModel(
      id: _s(json['id'] ?? json['_id']),
      chatId: _s(json['chatId'] ?? json['conversationId']),
      senderId: senderId,
      content: _s(json['content'] ?? json['text'] ?? json['message']),
      createdAt: _s(json['createdAt'] ?? json['timestamp'] ?? json['created_at']),
      isMe: isMeFlag,
      isRead: _bool(json['isRead'] ?? json['read']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'chatId': chatId,
        'senderId': senderId,
        'content': content,
        'createdAt': createdAt,
        'isMe': isMe,
        'isRead': isRead,
      };

  static String _s(dynamic v) => v?.toString() ?? '';
  static bool _bool(dynamic v) {
    if (v is bool) return v;
    if (v is String) return v.toLowerCase() == 'true';
    return false;
  }
}
