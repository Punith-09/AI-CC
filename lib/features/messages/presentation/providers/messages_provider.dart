import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/chat_model.dart';
import '../../data/models/message_model.dart';
import '../../data/repository/messages_repository.dart';

class MessagesProvider extends ChangeNotifier {
  final MessagesRepository _repository;

  MessagesProvider(this._repository);

  // =========================================================
  // STATE
  // =========================================================

  bool _isLoadingChats = false;
  bool get isLoadingChats => _isLoadingChats;

  bool _isLoadingMessages = false;
  bool get isLoadingMessages => _isLoadingMessages;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<ChatModel> _chats = [];
  List<ChatModel> get chats => List.unmodifiable(_chats);

  // Messages keyed by chatId
  final Map<String, List<MessageModel>> _messages = {};

  List<MessageModel> messagesForChat(String chatId) =>
      List.unmodifiable(_messages[chatId] ?? []);

  // =========================================================
  // FETCH CHATS
  // =========================================================

  Future<bool> fetchChats() async {
    _isLoadingChats = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('');
      print('========================================');
      print('💬 FETCH CHATS');
      print('========================================');

      final result = await _repository.getChats();
      _chats = result;

      _isLoadingChats = false;
      notifyListeners();

      print('========================================');
      print('✅ CHATS LOADED: ${_chats.length}');
      print('========================================');

      return true;
    } catch (e) {
      _isLoadingChats = false;
      _errorMessage = _cleanError(e);
      notifyListeners();

      print('❌ FETCH CHATS FAILED: $_errorMessage');
      return false;
    }
  }

  // =========================================================
  // FETCH MESSAGES FOR CHAT
  // =========================================================

  Future<bool> fetchMessages(String chatId) async {
    _isLoadingMessages = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('');
      print('========================================');
      print('📨 FETCH MESSAGES FOR CHAT: $chatId');
      print('========================================');

      final result = await _repository.getChatMessages(chatId);
      _messages[chatId] = result;

      _isLoadingMessages = false;
      notifyListeners();

      print('✅ MESSAGES LOADED: ${result.length}');

      return true;
    } catch (e) {
      _isLoadingMessages = false;
      _errorMessage = _cleanError(e);
      notifyListeners();

      print('❌ FETCH MESSAGES FAILED: $_errorMessage');
      return false;
    }
  }

  // =========================================================
  // START CHAT
  // =========================================================

  Future<ChatModel?> startChat(String userId) async {
    try {
      final chat = await _repository.startChat(userId);

      // Add to chats list if not already present
      final exists = _chats.any((c) => c.id == chat.id);
      if (!exists) {
        _chats.insert(0, chat);
        notifyListeners();
      }

      return chat;
    } catch (e) {
      _errorMessage = _cleanError(e);
      notifyListeners();
      return null;
    }
  }

  // =========================================================
  // CLEAR ERROR
  // =========================================================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // =========================================================
  // ERROR HANDLER
  // =========================================================

  String _cleanError(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final responseData = error.response?.data;

      if (responseData is Map<String, dynamic>) {
        final msg = responseData['message'];
        if (msg is String && msg.isNotEmpty) return msg;
        if (msg is List && msg.isNotEmpty) return msg.join('\n');
        final err = responseData['error'];
        if (err is String && err.isNotEmpty) return err;
      }

      switch (statusCode) {
        case 401:
          return 'Session expired. Please login again.';
        case 403:
          return 'You are not allowed to perform this action.';
        case 404:
          return 'Chat not found.';
        case 500:
          return 'Server error. Please try again later.';
      }

      return error.message ?? 'Something went wrong.';
    }

    return error.toString();
  }
}
