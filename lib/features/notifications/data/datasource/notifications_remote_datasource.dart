import '../../../../core/api/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<int> getUnreadCount();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String id);
  Future<void> clearAllNotifications();
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  final DioClient _client;

  NotificationsRemoteDataSourceImpl(this._client);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final response = await _client.get(ApiEndpoints.notifications);
    final data = response.data;
    if (data is List) {
      return data
          .map((item) =>
              NotificationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final list = data['notifications'] ?? data['data'] ?? [];
      if (list is List) {
        return list
            .map((item) =>
                NotificationModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  @override
  Future<int> getUnreadCount() async {
    final response =
        await _client.get(ApiEndpoints.notificationsUnreadCount);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['count'] as int? ??
          data['unreadCount'] as int? ??
          data['unread'] as int? ??
          0;
    }
    if (data is int) return data;
    return 0;
  }

  @override
  Future<void> markAsRead(String id) async {
    await _client.post(ApiEndpoints.markNotificationRead(id));
  }

  @override
  Future<void> markAllAsRead() async {
    await _client.post(ApiEndpoints.markAllNotificationsRead);
  }

  @override
  Future<void> deleteNotification(String id) async {
    await _client.delete(ApiEndpoints.deleteNotification(id));
  }

  @override
  Future<void> clearAllNotifications() async {
    await _client.delete(ApiEndpoints.clearAllNotifications);
  }
}
