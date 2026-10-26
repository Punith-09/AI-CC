import 'package:flutter/material.dart';
import '../../data/repository/notifications_repository.dart';
import '../../data/models/notification_model.dart';

class NotificationsProvider extends ChangeNotifier {
  final NotificationsRepository _repository;

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _error;

  NotificationsProvider(this._repository);

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get error => _error;

  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  List<NotificationModel> get readNotifications =>
      _notifications.where((n) => n.isRead).toList();

  Future<void> fetchNotifications({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }
    try {
      _notifications = await _repository.getNotifications();
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '').trim();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      _unreadCount = await _repository.getUnreadCount();
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> markAsRead(String id) async {
    _isActionLoading = true;
    notifyListeners();
    try {
      await _repository.markAsRead(id);
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx != -1) {
        _notifications[idx] = _notifications[idx].copyWith(isRead: true);
        if (_unreadCount > 0) _unreadCount--;
      }
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '').trim();
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markAllAsRead() async {
    _isActionLoading = true;
    notifyListeners();
    try {
      await _repository.markAllAsRead();
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      _unreadCount = 0;
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '').trim();
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteNotification(String id) async {
    _isActionLoading = true;
    notifyListeners();
    try {
      await _repository.deleteNotification(id);
      final removed = _notifications.firstWhere(
        (n) => n.id == id,
        orElse: () => NotificationModel(
          id: '',
          title: '',
          message: '',
          type: '',
          isRead: true,
          createdAt: DateTime.now(),
        ),
      );
      _notifications.removeWhere((n) => n.id == id);
      if (!removed.isRead && _unreadCount > 0) _unreadCount--;
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '').trim();
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> clearAllNotifications() async {
    _isActionLoading = true;
    notifyListeners();
    try {
      await _repository.clearAllNotifications();
      _notifications = [];
      _unreadCount = 0;
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '').trim();
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }
}
