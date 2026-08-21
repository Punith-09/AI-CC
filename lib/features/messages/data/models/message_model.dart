import 'package:flutter/foundation.dart';

@immutable
class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final String createdAt;
  final bool isRead;

  const MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.isRead = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: _s(json['id'] ?? json['_id']),
      chatId: _s(json['chatId'] ?? json['conversationId']),
      senderId: _s(
        json['senderId'] ??
            (json['sender'] is Map ? json['sender']['id'] ?? json['sender']['_id'] : json['sender']),
      ),
      content: _s(json['content'] ?? json['text'] ?? json['message']),
      createdAt: _s(json['createdAt'] ?? json['timestamp']),
      isRead: _bool(json['isRead'] ?? json['read']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'chatId': chatId,
        'senderId': senderId,
        'content': content,
        'createdAt': createdAt,
        'isRead': isRead,
      };

  static String _s(dynamic v) => v?.toString() ?? '';
  static bool _bool(dynamic v) {
    if (v is bool) return v;
    if (v is String) return v.toLowerCase() == 'true';
    return false;
  }
}
