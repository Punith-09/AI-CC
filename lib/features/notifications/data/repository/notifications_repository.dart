import '../datasource/notifications_remote_datasource.dart';
import '../models/notification_model.dart';

abstract class NotificationsRepository {
  Future<List<NotificationModel>> getNotifications();
  Future<int> getUnreadCount();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String id);
  Future<void> clearAllNotifications();
}

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource _dataSource;

  NotificationsRepositoryImpl(this._dataSource);

  @override
  Future<List<NotificationModel>> getNotifications() =>
      _dataSource.getNotifications();

  @override
  Future<int> getUnreadCount() => _dataSource.getUnreadCount();

  @override
  Future<void> markAsRead(String id) => _dataSource.markAsRead(id);

  @override
  Future<void> markAllAsRead() => _dataSource.markAllAsRead();

  @override
  Future<void> deleteNotification(String id) =>
      _dataSource.deleteNotification(id);

  @override
  Future<void> clearAllNotifications() => _dataSource.clearAllNotifications();
}
