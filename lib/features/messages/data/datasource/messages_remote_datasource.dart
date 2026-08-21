import 'package:dio/dio.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

abstract class MessagesRemoteDataSource {
  Future<List<ChatModel>> getChats();
  Future<List<MessageModel>> getChatMessages(String chatId);
  Future<ChatModel> startChat(String userId);
}

class MessagesRemoteDataSourceImpl implements MessagesRemoteDataSource {
  final DioClient _dioClient;

  MessagesRemoteDataSourceImpl(this._dioClient);

  // =========================================================
  // GET ALL CHATS
  // =========================================================

  @override
  Future<List<ChatModel>> getChats() async {
    try {
      print('');
      print('========================================');
      print('💬 GET CHATS');
      print('========================================');
      print('URL: ${ApiEndpoints.chats}');
      print('METHOD: GET');
      print('========================================');

      final response = await _dioClient.get(ApiEndpoints.chats);

      print('');
      print('========================================');
      print('✅ GET CHATS SUCCESS');
      print('STATUS: ${response.statusCode}');
      print('RESPONSE: ${response.data}');
      print('========================================');

      final List<dynamic>? list = _extractList(response.data);

      if (list == null) {
        return [];
      }

      final chats = <ChatModel>[];

      for (final item in list) {
        if (item is Map<String, dynamic>) {
          chats.add(ChatModel.fromJson(item));
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
      print('');
      print('========================================');
      print('📨 GET CHAT MESSAGES');
      print('========================================');
      print('CHAT ID: $chatId');
      print('URL: ${ApiEndpoints.chatMessages(chatId)}');
      print('METHOD: GET');
      print('========================================');

      final response = await _dioClient.get(
        ApiEndpoints.chatMessages(chatId),
      );

      print('');
      print('========================================');
      print('✅ GET MESSAGES SUCCESS');
      print('STATUS: ${response.statusCode}');
      print('RESPONSE: ${response.data}');
      print('========================================');

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
      print('');
      print('========================================');
      print('🚀 START CHAT');
      print('========================================');
      print('USER ID: $userId');
      print('URL: ${ApiEndpoints.startChat(userId)}');
      print('METHOD: POST');
      print('========================================');

      final response = await _dioClient.post(
        ApiEndpoints.startChat(userId),
      );

      print('');
      print('========================================');
      print('✅ START CHAT SUCCESS');
      print('STATUS: ${response.statusCode}');
      print('RESPONSE: ${response.data}');
      print('========================================');

      final Map<String, dynamic>? chatJson = _extractMap(response.data);

      if (chatJson == null) {
        throw Exception('Invalid server response for start chat.');
      }

      return ChatModel.fromJson(chatJson);
    } on DioException catch (e) {
      _printDioError('START CHAT ERROR', e);
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
