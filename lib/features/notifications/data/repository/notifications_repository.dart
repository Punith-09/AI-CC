import '../datasource/notifications_remote_datasource.dart';
import '../models/notification_model.dart';

abstract class NotificationsRepository {
  Future<List<NotificationModel>> getNotifications();
  Future<bool> clearAllNotifications();
  Future<bool> markAllAsRead();
}

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource _dataSource;

  NotificationsRepositoryImpl(this._dataSource);

  @override
  Future<List<NotificationModel>> getNotifications() =>
      _dataSource.getNotifications();

  @override
  Future<bool> clearAllNotifications() => _dataSource.clearAllNotifications();

  @override
  Future<bool> markAllAsRead() => _dataSource.markAllAsRead();
}
