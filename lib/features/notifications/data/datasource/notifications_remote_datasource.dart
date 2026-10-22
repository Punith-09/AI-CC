import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<bool> clearAllNotifications();
  Future<bool> markAllAsRead();
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final DioClient _dioClient;

  NotificationsRemoteDataSourceImpl(this._dioClient);

  // ============================
  // GET NOTIFICATIONS
  // ============================

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.notifications);

      if (response.data is List) {
        final list = response.data as List;
        return list
            .whereType<Map<String, dynamic>>()
            .map(NotificationModel.fromJson)
            .toList();
      }

      // Some backends wrap the list in { data: [...] }
      if (response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        final raw = map['data'] ?? map['notifications'] ?? map['alerts'];
        if (raw is List) {
          return raw
              .whereType<Map<String, dynamic>>()
              .map(NotificationModel.fromJson)
              .toList();
        }
      }

      return [];
    } on DioException catch (e) {
      _handleDioError('GET NOTIFICATIONS', e);
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
    return [];
  }

  // ============================
  // CLEAR ALL NOTIFICATIONS
  // ============================

  @override
  Future<bool> clearAllNotifications() async {
    try {
      final response = await _dioClient.delete(ApiEndpoints.notifications);

      if (response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        return map['success'] as bool? ?? true;
      }
      return true;
    } on DioException catch (e) {
      _handleDioError('CLEAR NOTIFICATIONS', e);
    } catch (e) {
      throw Exception('Failed to clear notifications: $e');
    }
    return false;
  }

  // ============================
  // MARK ALL AS READ
  // ============================

  @override
  Future<bool> markAllAsRead() async {
    try {
      final response = await _dioClient.post(ApiEndpoints.notificationsReadAll);

      if (response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        return map['success'] as bool? ?? true;
      }
      return true;
    } on DioException catch (e) {
      _handleDioError('MARK ALL READ', e);
    } catch (e) {
      throw Exception('Failed to mark notifications as read: $e');
    }
    return false;
  }

  // ============================
  // HELPER
  // ============================

  Never _handleDioError(String tag, DioException e) {
    print('❌ [$tag] DIO ERROR: status=${e.response?.statusCode}, data=${e.response?.data}');
    final responseData = e.response?.data;
    if (responseData is Map) {
      final rawMsg = responseData['message'] ?? responseData['error'];
      String msg = '';
      if (rawMsg is List) {
        msg = (rawMsg as List).join(', ');
      } else if (rawMsg != null) {
        msg = rawMsg.toString();
      }
      if (msg.isNotEmpty && !msg.toLowerCase().contains('internal server error')) {
        throw Exception(msg);
      }
    }
    throw Exception('Request failed. Please check your connection.');
  }
}
