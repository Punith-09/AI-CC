import 'package:flutter/foundation.dart';
import '../../data/models/notification_model.dart';
import '../../data/repository/notifications_repository.dart';

class NotificationsProvider extends ChangeNotifier {
  final NotificationsRepository _repository;

  NotificationsProvider(this._repository);

  // =========================================================
  // STATE
  // =========================================================

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isActing = false; // for clear / mark-all-read operations
  bool get isActing => _isActing;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Unread count badge shown in the home appbar
  int get unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  bool get hasUnread => unreadCount > 0;

  // =========================================================
  // FETCH
  // =========================================================

  Future<void> fetchNotifications({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final result = await _repository.getNotifications();
      _notifications = result;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================================================
  // MARK ALL AS READ
  // =========================================================

  Future<void> markAllAsRead() async {
    if (_notifications.every((n) => n.isRead)) return; // nothing to do
    _isActing = true;
    notifyListeners();

    try {
      await _repository.markAllAsRead();
      // Optimistic local update
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
    } catch (e) {
      // Silently swallow; the badge will re-sync on next fetch
      debugPrint('⚠️ markAllAsRead failed: $e');
    } finally {
      _isActing = false;
      notifyListeners();
    }
  }

  // =========================================================
  // CLEAR ALL
  // =========================================================

  Future<void> clearAllNotifications() async {
    _isActing = true;
    notifyListeners();

    try {
      await _repository.clearAllNotifications();
      _notifications = [];
    } catch (e) {
      debugPrint('⚠️ clearAllNotifications failed: $e');
    } finally {
      _isActing = false;
      notifyListeners();
    }
  }
}
