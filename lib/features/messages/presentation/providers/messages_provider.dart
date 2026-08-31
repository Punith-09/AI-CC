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

  // ignore: prefer_final_fields
  bool _isSending = false;
  bool get isSending => _isSending;

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
      final result = await _repository.getChats();
      _chats = result;
      _isLoadingChats = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoadingChats = false;
      _errorMessage = _cleanError(e);
      notifyListeners();
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
      final result = await _repository.getChatMessages(chatId);
      _messages[chatId] = result;
      _isLoadingMessages = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoadingMessages = false;
      _errorMessage = _cleanError(e);
      notifyListeners();
      return false;
    }
  }

  // =========================================================
  // SEND MESSAGE
  // =========================================================

  Future<bool> sendMessage(String chatId, String text) async {
    if (text.trim().isEmpty) return false;

    // Optimistic update — add a temp message immediately
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final tempMsg = MessageModel(
      id: tempId,
      chatId: chatId,
      senderId: '',
      content: text.trim(),
      createdAt: DateTime.now().toIso8601String(),
      isMe: true,
    );
    _messages[chatId] = [...(_messages[chatId] ?? []), tempMsg];
    notifyListeners();

    try {
      final result = await _repository.sendMessage(chatId, text.trim());

      // Replace temp message with real one
      final msgs = List<MessageModel>.from(_messages[chatId] ?? []);
      final tempIdx = msgs.indexWhere((m) => m.id == tempId);
      if (tempIdx != -1) {
        msgs[tempIdx] = result.isMe ? result : MessageModel(
          id: result.id,
          chatId: result.chatId,
          senderId: result.senderId,
          content: result.content,
          createdAt: result.createdAt,
          isMe: true, // we sent it
          isRead: result.isRead,
        );
      } else {
        msgs.add(result);
      }
      _messages[chatId] = msgs;

      // Update last message in chats list
      final chatIdx = _chats.indexWhere((c) => c.id == chatId);
      if (chatIdx != -1) {
        final old = _chats[chatIdx];
        _chats[chatIdx] = ChatModel(
          id: old.id,
          participantId: old.participantId,
          participantName: old.participantName,
          participantAvatar: old.participantAvatar,
          participantRole: old.participantRole,
          lastMessage: text.trim(),
          lastMessageAt: DateTime.now().toIso8601String(),
          unreadCount: old.unreadCount,
          isOnline: old.isOnline,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      // Remove temp message on failure
      final msgs = List<MessageModel>.from(_messages[chatId] ?? []);
      msgs.removeWhere((m) => m.id == tempId);
      _messages[chatId] = msgs;
      _errorMessage = _cleanError(e);
      notifyListeners();
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
