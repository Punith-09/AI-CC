import 'package:dio/dio.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/local_storage.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

abstract class MessagesRemoteDataSource {
  Future<List<ChatModel>> getChats();
  Future<List<MessageModel>> getChatMessages(String chatId);
  Future<ChatModel> startChat(String userId);
  Future<MessageModel> sendMessage(String chatId, String text);
}

class MessagesRemoteDataSourceImpl implements MessagesRemoteDataSource {
  final DioClient _dioClient;

  MessagesRemoteDataSourceImpl(this._dioClient);

  // =========================================================
  // USER DIRECTORY HELPER
  // =========================================================

  Map<String, String> _extractUserInfo(dynamic raw) {
    if (raw == null) return {};
    Map<String, dynamic> u = {};
    if (raw is Map<String, dynamic>) {
      if (raw['data'] is Map<String, dynamic>) {
        final d = raw['data'] as Map<String, dynamic>;
        u = d['user'] is Map<String, dynamic>
            ? d['user'] as Map<String, dynamic>
            : (d['talent'] is Map<String, dynamic> ? d['talent'] as Map<String, dynamic> : d);
      } else if (raw['user'] is Map<String, dynamic>) {
        u = raw['user'] as Map<String, dynamic>;
      } else if (raw['talent'] is Map<String, dynamic>) {
        u = raw['talent'] as Map<String, dynamic>;
      } else {
        u = raw;
      }
    }

    final id = (u['_id'] ?? u['id'] ?? u['userId'])?.toString().trim() ?? '';
    final name = (u['fullName'] ?? u['name'] ?? u['username'] ?? u['displayName'] ?? u['handle'])
            ?.toString()
            .trim() ??
        '';
    final avatar = (u['profilePhoto'] ??
            u['profileImage'] ??
            u['profile_photo'] ??
            u['profile_image'] ??
            u['avatar'] ??
            u['pic'] ??
            u['photo'] ??
            u['image'])
            ?.toString()
            .trim() ??
        '';

    String role = '';
    final rawRole = u['role'] ?? u['roles'] ?? u['category'] ?? u['type'] ?? u['profession'];
    if (rawRole is List && rawRole.isNotEmpty) {
      role = rawRole.first.toString().trim();
    } else if (rawRole != null) {
      role = rawRole.toString().trim();
    }

    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'role': role,
    };
  }

  Future<Map<String, Map<String, String>>> _fetchUsersDirectory() async {
    final Map<String, Map<String, String>> userMap = {};
    try {
      final response = await _dioClient.get(ApiEndpoints.exploreUsers);
      dynamic listData;
      if (response.data is List) {
        listData = response.data;
      } else if (response.data is Map) {
        listData = response.data['data'] ??
            response.data['users'] ??
            response.data['talents'] ??
            response.data['results'];
      }

      if (listData is List) {
        for (final item in listData) {
          if (item is Map<String, dynamic>) {
            final info = _extractUserInfo(item);
            if (info['id'] != null && info['id']!.isNotEmpty) {
              userMap[info['id']!] = info;
            }
          }
        }
      }
    } catch (_) {}
    return userMap;
  }

  // =========================================================
  // GET ALL CHATS
  // =========================================================

  @override
  Future<List<ChatModel>> getChats() async {
    try {
      // 1. Ensure currentUserId is known
      String currentUserId = LocalStorage.instance.getUserId() ?? '';
      if (currentUserId.isEmpty) {
        try {
          final meRes = await _dioClient.get(ApiEndpoints.profileMe);
          if (meRes.data is Map) {
            final meData = meRes.data['data'] ?? meRes.data['user'] ?? meRes.data;
            if (meData is Map) {
              final meId = meData['_id']?.toString() ?? meData['id']?.toString() ?? meData['userId']?.toString() ?? '';
              if (meId.isNotEmpty) {
                currentUserId = meId;
                await LocalStorage.instance.saveUserId(meId);
              }
            }
          }
        } catch (_) {}
      }

      // 2. Fetch chats & user directory in parallel
      final results = await Future.wait([
        _dioClient.get(ApiEndpoints.chats),
        _fetchUsersDirectory(),
      ]);

      final response = results[0] as Response;
      final usersDirectory = results[1] as Map<String, Map<String, String>>;

      final List<dynamic>? list = _extractList(response.data);
      if (list == null) return [];

      final chats = <ChatModel>[];

      for (final item in list) {
        if (item is Map<String, dynamic>) {
          var chat = ChatModel.fromJson(item, currentUserId: currentUserId);

          // If participantId is empty or equal to current user, resolve it from raw item
          if (chat.participantId.isEmpty || chat.participantId == currentUserId) {
            final rawParticipants = item['participants'] ?? item['users'] ?? item['members'];
            if (rawParticipants is List) {
              for (final p in rawParticipants) {
                String pId = '';
                if (p is Map) {
                  pId = (p['_id'] ?? p['id'] ?? p['userId'])?.toString() ?? '';
                } else if (p != null) {
                  pId = p.toString();
                }
                if (pId.isNotEmpty && pId != currentUserId) {
                  chat = chat.copyWith(participantId: pId);
                  break;
                }
              }
            }
          }

          // If participantId is STILL empty, check chat messages
          if (chat.participantId.isEmpty && chat.id.isNotEmpty) {
            try {
              final msgRes = await _dioClient.get(ApiEndpoints.chatMessages(chat.id));
              final msgList = _extractList(msgRes.data);
              if (msgList != null) {
                for (final m in msgList) {
                  if (m is Map<String, dynamic>) {
                    final sId = (m['senderId'] ??
                            (m['sender'] is Map
                                ? m['sender']['_id'] ?? m['sender']['id']
                                : m['sender']))
                        ?.toString() ??
                        '';
                    if (sId.isNotEmpty && sId != currentUserId && sId != 'me') {
                      chat = chat.copyWith(participantId: sId);
                      break;
                    }
                  }
                }
              }
            } catch (_) {}
          }

          // Resolve name, avatar, and role if missing
          if (chat.participantName.isEmpty || chat.participantAvatar.isEmpty) {
            // First check usersDirectory cache
            if (chat.participantId.isNotEmpty && usersDirectory.containsKey(chat.participantId)) {
              final info = usersDirectory[chat.participantId]!;
              chat = chat.copyWith(
                participantName: chat.participantName.isNotEmpty ? chat.participantName : info['name'],
                participantAvatar: chat.participantAvatar.isNotEmpty ? chat.participantAvatar : info['avatar'],
                participantRole: chat.participantRole.isNotEmpty ? chat.participantRole : info['role'],
              );
            }

            // If still missing name, fetch individual user profile
            if (chat.participantName.isEmpty && chat.participantId.isNotEmpty) {
              try {
                final userRes = await _dioClient.get(ApiEndpoints.userProfile(chat.participantId));
                final info = _extractUserInfo(userRes.data);
                if (info['name']?.isNotEmpty == true) {
                  chat = chat.copyWith(
                    participantName: info['name'],
                    participantAvatar: info['avatar'],
                    participantRole: info['role'],
                  );
                }
              } catch (_) {}
            }
          }

          chats.add(chat);
        }
      }

      return chats;
    } on DioException catch (e) {
      _printDioError('GET CHATS ERROR', e);
      rethrow;
    }
  }

  // =========================================================
  // GET CHAT MESSAGES
  // =========================================================

  @override
  Future<List<MessageModel>> getChatMessages(String chatId) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.chatMessages(chatId),
      );

      final List<dynamic>? list = _extractList(response.data);

      if (list == null) {
        return [];
      }

      final messages = <MessageModel>[];

      for (final item in list) {
        if (item is Map<String, dynamic>) {
          messages.add(MessageModel.fromJson(item));
        }
      }

      return messages;
    } on DioException catch (e) {
      _printDioError('GET CHAT MESSAGES ERROR', e);
      rethrow;
    }
  }

  // =========================================================
  // START CHAT
  // =========================================================

  @override
  Future<ChatModel> startChat(String userId) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.startChat(userId),
      );

      final data = response.data;
      String chatId = '';
      if (data is Map) {
        chatId = data['chatId']?.toString() ??
            data['id']?.toString() ??
            data['_id']?.toString() ??
            '';
      }

      if (chatId.isEmpty) {
        throw Exception('No chatId returned from start chat.');
      }

      // Fetch user profile to get participant details
      String participantName = '';
      String participantAvatar = '';
      String participantRole = '';
      try {
        final profileRes = await _dioClient.get(ApiEndpoints.userProfile(userId));
        final info = _extractUserInfo(profileRes.data);
        participantName = info['name'] ?? '';
        participantAvatar = info['avatar'] ?? '';
        participantRole = info['role'] ?? '';
      } catch (_) {}

      if (participantName.isEmpty) {
        try {
          final usersDir = await _fetchUsersDirectory();
          if (usersDir.containsKey(userId)) {
            final info = usersDir[userId]!;
            participantName = info['name'] ?? '';
            participantAvatar = info['avatar'] ?? '';
            participantRole = info['role'] ?? '';
          }
        } catch (_) {}
      }

      return ChatModel(
        id: chatId,
        participantId: userId,
        participantName: participantName,
        participantAvatar: participantAvatar,
        participantRole: participantRole,
      );
    } on DioException catch (e) {
      _printDioError('START CHAT ERROR', e);
      rethrow;
    }
  }

  // =========================================================
  // SEND MESSAGE
  // =========================================================

  @override
  Future<MessageModel> sendMessage(String chatId, String text) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.chatMessages(chatId),
        data: {'text': text},
      );

      final Map<String, dynamic>? messageJson = _extractMap(response.data);

      if (messageJson == null) {
        throw Exception('Invalid server response for send message.');
      }

      return MessageModel.fromJson(messageJson);
    } on DioException catch (e) {
      _printDioError('SEND MESSAGE ERROR', e);
      rethrow;
    }
  }

  // =========================================================
  // HELPERS
  // =========================================================

  List<dynamic>? _extractList(dynamic data) {
    if (data is List) return data;

    if (data is Map<String, dynamic>) {
      if (data['chats'] is List) return data['chats'];
      if (data['messages'] is List) return data['messages'];
      if (data['data'] is List) return data['data'];

      if (data['data'] is Map<String, dynamic>) {
        final inner = data['data'] as Map<String, dynamic>;
        if (inner['chats'] is List) return inner['chats'];
        if (inner['messages'] is List) return inner['messages'];
        if (inner['data'] is List) return inner['data'];
      }
    }

    return null;
  }

  Map<String, dynamic>? _extractMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['chat'] is Map<String, dynamic>) return data['chat'];
      if (data['data'] is Map<String, dynamic>) {
        final inner = data['data'] as Map<String, dynamic>;
        if (inner['chat'] is Map<String, dynamic>) return inner['chat'];
        return inner;
      }
      return data;
    }
    return null;
  }

  void _printDioError(String title, DioException e) {
    print('');
    print('========================================');
    print('❌ $title');
    print('========================================');
    print('STATUS: ${e.response?.statusCode}');
    print('URL: ${e.requestOptions.uri}');
    print('METHOD: ${e.requestOptions.method}');
    print('RESPONSE: ${e.response?.data}');
    print('MESSAGE: ${e.message}');
    print('========================================');
  }
}
