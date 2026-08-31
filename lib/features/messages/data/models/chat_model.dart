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

  factory ChatModel.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    String participantId = '';
    String participantName = '';
    String participantAvatar = '';
    String participantRole = '';

    // Helper to safely extract user map
    Map<String, dynamic>? extractUserMap(dynamic val) {
      if (val is! Map<String, dynamic>) return null;
      if (val['user'] is Map<String, dynamic>) return val['user'] as Map<String, dynamic>;
      if (val['talent'] is Map<String, dynamic>) return val['talent'] as Map<String, dynamic>;
      return val;
    }

    void applyUserMap(Map<String, dynamic> u) {
      final id = _s(u['id'] ?? u['_id'] ?? u['userId']);
      if (participantId.isEmpty && id.isNotEmpty && id != currentUserId) {
        participantId = id;
      }
      if (participantName.isEmpty) {
        participantName = _s(u['fullName'] ?? u['name'] ?? u['username'] ?? u['displayName'] ?? u['handle']);
      }
      if (participantAvatar.isEmpty) {
        participantAvatar = _s(u['profilePhoto'] ?? u['profileImage'] ?? u['profile_photo'] ?? u['profile_image'] ?? u['avatar'] ?? u['pic'] ?? u['photo'] ?? u['image']);
      }
      if (participantRole.isEmpty) {
        final r = u['role'] ?? u['roles'] ?? u['category'] ?? u['type'] ?? u['profession'];
        if (r is List && r.isNotEmpty) {
          participantRole = _s(r.first);
        } else if (r != null) {
          participantRole = _s(r);
        }
      }
    }

    // 0. Direct Swagger backend fields: creatorId, creatorName, creatorPic
    if (participantId.isEmpty) {
      participantId = _s(json['creatorId'] ?? json['creator_id']);
    }
    if (participantName.isEmpty) {
      participantName = _s(json['creatorName'] ?? json['creator_name']);
    }
    if (participantAvatar.isEmpty) {
      participantAvatar = _s(json['creatorPic'] ?? json['creator_pic']);
    }

    // 1. Check if participants / users / members is a List
    final dynamic rawList = json['participants'] ?? json['users'] ?? json['members'];
    if (rawList is List && rawList.isNotEmpty) {
      Map<String, dynamic>? otherMap;
      String otherStringId = '';

      for (final item in rawList) {
        if (item is Map<String, dynamic>) {
          final u = extractUserMap(item) ?? item;
          final itemId = _s(u['id'] ?? u['_id'] ?? u['userId']);
          if (currentUserId != null && currentUserId.isNotEmpty && itemId == currentUserId) {
            continue; // Skip me
          }
          otherMap = u;
          break;
        } else if (item is String) {
          final str = item.trim();
          if (currentUserId != null && currentUserId.isNotEmpty && str == currentUserId) {
            continue; // Skip me
          }
          otherStringId = str;
          break;
        }
      }

      if (otherMap != null) {
        applyUserMap(otherMap);
      } else if (otherStringId.isNotEmpty && participantId.isEmpty) {
        participantId = otherStringId;
      } else if (rawList.first is Map<String, dynamic>) {
        applyUserMap(extractUserMap(rawList.first) ?? rawList.first as Map<String, dynamic>);
      } else if (rawList.first is String && participantId.isEmpty) {
        participantId = rawList.first.toString();
      }
    }

    // 2. Check user1 / user2 or sender / receiver / recipient
    final userCandidates = [
      json['otherParticipant'],
      json['otherUser'],
      json['recipient'],
      json['receiver'],
      json['target'],
      json['partner'],
      json['artist'],
      json['talent'],
      json['user'],
      json['user2'],
      json['user1'],
      json['sender'],
    ];

    for (final cand in userCandidates) {
      if (cand is Map<String, dynamic>) {
        final u = extractUserMap(cand) ?? cand;
        final candId = _s(u['id'] ?? u['_id'] ?? u['userId']);
        if (currentUserId != null && currentUserId.isNotEmpty && candId == currentUserId) {
          continue;
        }
        applyUserMap(u);
        if (participantName.isNotEmpty) break;
      } else if (cand is String && cand.isNotEmpty) {
        if (participantId.isEmpty && (currentUserId == null || cand != currentUserId)) {
          participantId = cand;
        }
      }
    }

    // 3. Fallback if flat on root object
    if (participantId.isEmpty) {
      participantId = _s(
        json['participantId'] ??
            json['userId'] ??
            json['targetUserId'] ??
            json['otherUserId'] ??
            json['recipientId'] ??
            json['receiverId'] ??
            json['artistId'] ??
            json['creatorId'] ??
            json['creator_id'],
      );
    }
    if (participantName.isEmpty) {
      participantName = _s(
        json['participantName'] ??
            json['creatorName'] ??
            json['creator_name'] ??
            json['otherUserName'] ??
            json['recipientName'] ??
            json['receiverName'] ??
            json['fullName'] ??
            json['name'] ??
            json['username'] ??
            json['title'],
      );
    }
    if (participantAvatar.isEmpty) {
      participantAvatar = _s(
        json['participantAvatar'] ??
            json['creatorPic'] ??
            json['creator_pic'] ??
            json['otherUserAvatar'] ??
            json['recipientAvatar'] ??
            json['receiverAvatar'] ??
            json['profilePhoto'] ??
            json['profileImage'] ??
            json['profile_photo'] ??
            json['profile_image'] ??
            json['avatar'] ??
            json['pic'] ??
            json['photo'] ??
            json['image'],
      );
    }
    if (participantRole.isEmpty) {
      final r = json['participantRole'] ??
          json['role'] ??
          json['roles'] ??
          json['category'] ??
          json['type'] ??
          json['profession'];
      if (r is List && r.isNotEmpty) {
        participantRole = _s(r.first);
      } else if (r != null) {
        participantRole = _s(r);
      }
    }

    // Last message
    final dynamic rawLastMsg = json['lastMessage'] ?? json['last_message'] ?? json['latestMessage'];
    String lastMessage = '';
    if (rawLastMsg is Map<String, dynamic>) {
      lastMessage = _s(rawLastMsg['content'] ?? rawLastMsg['text'] ?? rawLastMsg['message'] ?? rawLastMsg['body']);
    } else {
      lastMessage = _s(rawLastMsg);
    }

    // Unread
    final dynamic unreadRaw = json['unread'] ?? json['unreadCount'];
    int unreadCount = 0;
    if (unreadRaw is bool) {
      unreadCount = unreadRaw ? 1 : 0;
    } else {
      unreadCount = _int(unreadRaw);
    }

    return ChatModel(
      id: _s(json['id'] ?? json['_id'] ?? json['chatId']),
      participantId: participantId,
      participantName: participantName,
      participantAvatar: participantAvatar,
      participantRole: participantRole,
      lastMessage: lastMessage,
      lastMessageAt: _s(
        json['time'] ??
            json['lastMessageAt'] ??
            json['updatedAt'] ??
            json['createdAt'],
      ),
      unreadCount: unreadCount,
      isOnline: _bool(json['isOnline'] ?? json['online']),
    );
  }

  ChatModel copyWith({
    String? id,
    String? participantId,
    String? participantName,
    String? participantAvatar,
    String? participantRole,
    String? lastMessage,
    String? lastMessageAt,
    int? unreadCount,
    bool? isOnline,
  }) {
    return ChatModel(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      participantName: participantName ?? this.participantName,
      participantAvatar: participantAvatar ?? this.participantAvatar,
      participantRole: participantRole ?? this.participantRole,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
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
