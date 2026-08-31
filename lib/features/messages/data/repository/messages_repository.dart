import '../datasource/messages_remote_datasource.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

abstract class MessagesRepository {
  Future<List<ChatModel>> getChats();
  Future<List<MessageModel>> getChatMessages(String chatId);
  Future<ChatModel> startChat(String userId);
  Future<MessageModel> sendMessage(String chatId, String text);
}

class MessagesRepositoryImpl implements MessagesRepository {
  final MessagesRemoteDataSource _remoteDataSource;

  MessagesRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ChatModel>> getChats() {
    return _remoteDataSource.getChats();
  }

  @override
  Future<List<MessageModel>> getChatMessages(String chatId) {
    return _remoteDataSource.getChatMessages(chatId);
  }

  @override
  Future<ChatModel> startChat(String userId) {
    return _remoteDataSource.startChat(userId);
  }

  @override
  Future<MessageModel> sendMessage(String chatId, String text) {
    return _remoteDataSource.sendMessage(chatId, text);
  }
}
