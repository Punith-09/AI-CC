import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/storage/local_storage.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/message_model.dart';
import '../../data/repository/messages_repository.dart';

class MessagesProvider extends ChangeNotifier {
  final MessagesRepository _repository;

  MessagesProvider(this._repository) {
    _loadLocalReadStates();
  }

  // =========================================================
  // LOCAL READ / UNREAD CACHE
  // =========================================================

  Set<String> _readChatIds = {};
  Set<String> _unreadChatIds = {};
  Map<String, String> _lastReadMessages = {};

  void _loadLocalReadStates() {
    try {
      _readChatIds = LocalStorage.instance.getReadChatIds();
      _unreadChatIds = LocalStorage.instance.getUnreadChatIds();
      _lastReadMessages = LocalStorage.instance.getLastReadMessages();
    } catch (_) {}
  }

  void _saveLocalReadStates() {
    try {
      LocalStorage.instance.saveReadChatIds(_readChatIds);
      LocalStorage.instance.saveUnreadChatIds(_unreadChatIds);
      LocalStorage.instance.saveLastReadMessages(_lastReadMessages);
    } catch (_) {}
  }

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

  // Total unread messages count across all chats
  int get totalUnreadCount =>
      _chats.fold<int>(0, (sum, chat) => sum + (chat.isUnread ? 1 : 0));

  // =========================================================
  // SORT CHATS (Most recent on top)
  // =========================================================

  void _sortChats() {
    _chats.sort((a, b) {
      final dtA = _parseChatDate(a.lastMessageAt);
      final dtB = _parseChatDate(b.lastMessageAt);
      return dtB.compareTo(dtA);
    });
  }

  DateTime _parseChatDate(String dateStr) {
    if (dateStr.trim().isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
    final clean = dateStr.trim();

    try {
      String iso = clean;
      if (iso.endsWith('Z') || iso.endsWith('z')) {
        iso = iso.substring(0, iso.length - 1);
      }
      if (iso.contains('+')) {
        iso = iso.split('+').first;
      }
      final parsed = DateTime.tryParse(iso) ?? DateTime.tryParse(clean);
      if (parsed != null) return parsed;
    } catch (_) {}

    final numVal = int.tryParse(clean);
    if (numVal != null) {
      if (numVal > 1000000000000) {
        return DateTime.fromMillisecondsSinceEpoch(numVal);
      } else if (numVal > 1000000000) {
        return DateTime.fromMillisecondsSinceEpoch(numVal * 1000);
      }
    }

    final timeMatch = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM|am|pm)?').firstMatch(clean);
    if (timeMatch != null) {
      int hour = int.parse(timeMatch.group(1)!);
      final minute = int.parse(timeMatch.group(2)!);
      final period = timeMatch.group(3)?.toUpperCase();
      if (period == 'PM' && hour < 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
    }

    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  // =========================================================
  // FETCH CHATS
  // =========================================================

  Future<bool> fetchChats({bool silent = false}) async {
    if (!silent) {
      _isLoadingChats = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final result = await _repository.getChats();
      _loadLocalReadStates();

      final List<ChatModel> resolvedChats = [];

      for (var chat in result) {
        if (_unreadChatIds.contains(chat.id)) {
          // Explicitly unread
          chat = chat.copyWith(unreadCount: chat.unreadCount > 0 ? chat.unreadCount : 1);
        } else if (_readChatIds.contains(chat.id)) {
          // Previously read — check if lastMessage has changed
          final lastReadText = _lastReadMessages[chat.id];
          if (lastReadText != null &&
              chat.lastMessage.isNotEmpty &&
              lastReadText != chat.lastMessage) {
            // New incoming message!
            chat = chat.copyWith(unreadCount: 1);
            _unreadChatIds.add(chat.id);
            _readChatIds.remove(chat.id);
          } else {
            chat = chat.copyWith(unreadCount: 0);
          }
        } else {
          // New chat encountered
          if (chat.unreadCount > 0) {
            _unreadChatIds.add(chat.id);
          } else {
            _readChatIds.add(chat.id);
            _lastReadMessages[chat.id] = chat.lastMessage;
          }
        }
        resolvedChats.add(chat);
      }

      _saveLocalReadStates();
      _chats = resolvedChats;
      _sortChats();
      _isLoadingChats = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoadingChats = false;
      if (!silent) {
        _errorMessage = _cleanError(e);
      }
      notifyListeners();
      return false;
    }
  }

  // =========================================================
  // FETCH MESSAGES FOR CHAT
  // =========================================================

  Future<bool> fetchMessages(String chatId, {bool silent = false}) async {
    if (!silent) {
      _isLoadingMessages = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final result = await _repository.getChatMessages(chatId);
      _messages[chatId] = result;

      // Update last message & move to top if new message exists
      if (result.isNotEmpty) {
        final latest = result.last;
        final chatIdx = _chats.indexWhere((c) => c.id == chatId);
        if (chatIdx != -1) {
          final old = _chats[chatIdx];
          final updated = old.copyWith(
            lastMessage: latest.content,
            lastMessageAt: latest.createdAt,
          );
          _chats.removeAt(chatIdx);
          _chats.insert(0, updated);
        }
      }

      _sortChats();
      _isLoadingMessages = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoadingMessages = false;
      if (!silent) {
        _errorMessage = _cleanError(e);
      }
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
    final nowIso = DateTime.now().toIso8601String();
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final tempMsg = MessageModel(
      id: tempId,
      chatId: chatId,
      senderId: '',
      content: text.trim(),
      createdAt: nowIso,
      isMe: true,
    );
    _messages[chatId] = [...(_messages[chatId] ?? []), tempMsg];

    // Optimistically update chat in list and MOVE TO TOP!
    _unreadChatIds.remove(chatId);
    _readChatIds.add(chatId);
    _lastReadMessages[chatId] = text.trim();
    _saveLocalReadStates();

    final chatIdx = _chats.indexWhere((c) => c.id == chatId);
    if (chatIdx != -1) {
      final old = _chats[chatIdx];
      final updated = old.copyWith(
        lastMessage: text.trim(),
        lastMessageAt: nowIso,
        unreadCount: 0,
      );
      _chats.removeAt(chatIdx);
      _chats.insert(0, updated);
    }
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
          isMe: true,
          isRead: result.isRead,
        );
      } else {
        msgs.add(result);
      }
      _messages[chatId] = msgs;

      // Ensure updated position at TOP
      final curIdx = _chats.indexWhere((c) => c.id == chatId);
      if (curIdx != -1) {
        final old = _chats[curIdx];
        final updated = old.copyWith(
          lastMessage: text.trim(),
          lastMessageAt: result.createdAt.isNotEmpty ? result.createdAt : nowIso,
          unreadCount: 0,
        );
        _chats.removeAt(curIdx);
        _chats.insert(0, updated);
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
  // MARK AS READ / UNREAD
  // =========================================================

  void markChatAsRead(String chatId) {
    _unreadChatIds.remove(chatId);
    _readChatIds.add(chatId);

    final idx = _chats.indexWhere((c) => c.id == chatId);
    if (idx != -1) {
      _lastReadMessages[chatId] = _chats[idx].lastMessage;
      _chats[idx] = _chats[idx].copyWith(unreadCount: 0);
    }
    _saveLocalReadStates();
    notifyListeners();
  }

  void markChatAsUnread(String chatId) {
    _readChatIds.remove(chatId);
    _unreadChatIds.add(chatId);

    final idx = _chats.indexWhere((c) => c.id == chatId);
    if (idx != -1) {
      _chats[idx] = _chats[idx].copyWith(unreadCount: 1);
    }
    _saveLocalReadStates();
    notifyListeners();
  }

  void toggleChatReadStatus(String chatId) {
    final idx = _chats.indexWhere((c) => c.id == chatId);
    if (idx != -1) {
      final isCurrentlyUnread = _chats[idx].isUnread;
      if (isCurrentlyUnread) {
        markChatAsRead(chatId);
      } else {
        markChatAsUnread(chatId);
      }
    }
  }

  // =========================================================
  // START CHAT
  // =========================================================

  Future<ChatModel?> startChat(String userId) async {
    try {
      final chat = await _repository.startChat(userId);

      _readChatIds.add(chat.id);
      _unreadChatIds.remove(chat.id);
      _saveLocalReadStates();

      // Add to top of chats list if not already present
      final idx = _chats.indexWhere((c) => c.id == chat.id);
      if (idx != -1) {
        final existing = _chats.removeAt(idx);
        _chats.insert(0, existing);
      } else {
        _chats.insert(0, chat);
      }
      notifyListeners();

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
