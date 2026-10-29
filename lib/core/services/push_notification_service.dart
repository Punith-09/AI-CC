import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../features/notifications/presentation/providers/notifications_provider.dart';
import '../../firebase_options.dart';
import '../api/api_endpoints.dart';
import '../di/injection_container.dart';
import '../network/dio_client.dart';
import '../storage/local_storage.dart';
import 'push_notification_navigator.dart';
import 'push_notification_payload.dart';

const String kAiccNotificationChannelId = 'aicc_high_importance';
const String kAiccNotificationChannelName = 'TreeKo notifications';
const String kAiccNotificationChannelDesc =
    'Likes, comments, follows, messages, and audition updates';

/// Top-level FCM background handler. Must be registered before [runApp].
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (_) {}

  // Notification+data messages are already shown by the OS. Data-only
  // messages need a local notification so the user still sees them.
  if (message.notification != null) return;
  await PushNotificationService.displayLocalNotification(
    PushNotificationPayload.fromRemoteMessage(message),
  );
}

@pragma('vm:entry-point')
void _onLocalNotificationBackgroundTap(NotificationResponse response) {
  final payload = PushNotificationPayload.tryParse(response.payload);
  if (payload != null) {
    PushNotificationNavigator.open(payload);
  }
}

/// Receives backend-sent FCM pushes and presents them.
///
/// Does not send notifications. This Flutter client has no device-token
/// registration endpoint, so the token is obtained locally only.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  static final FlutterLocalNotificationsPlugin _localPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _localPluginReady = false;
  static bool _initialized = false;

  final StreamController<PushNotificationPayload> _foregroundController =
      StreamController<PushNotificationPayload>.broadcast();

  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onOpenedSub;
  StreamSubscription<String>? _tokenSub;

  final Set<String> _recentKeys = {};
  bool _handlingLaunch = false;

  Stream<PushNotificationPayload> get foregroundBanners =>
      _foregroundController.stream;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    if (kIsWeb) return;

    await _initLocalNotifications();
    await _configureIosPresentation();
    await _requestPermissionGracefully();
    _bindForegroundListeners();
    await _handleLaunchMessages();
    // Register token with backend on every app launch.
    // _registerTokenWithBackend() guards against unauthenticated calls.
    await _registerTokenWithBackend();
  }

  void attachRouter() {
    PushNotificationNavigator.markRouterReady();
  }

  Future<void> onUserSignedIn() async {
    await _requestPermissionGracefully();
    await _registerTokenWithBackend();
    await _consumePendingLaunch();
  }

  Future<void> onUserSignedOut() async {
    // 1. Deregister token from backend so no more pushes are sent after logout
    await _clearTokenFromBackend();
    // 2. Delete the local FCM token so it is regenerated fresh on next login
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      debugPrint('FCM token delete failed: $e');
    }
  }

  void openPayload(PushNotificationPayload payload) {
    PushNotificationNavigator.open(payload);
  }

  Future<void> _initLocalNotifications() async {
    await _ensureLocalPlugin();
    final android = _localPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        kAiccNotificationChannelId,
        kAiccNotificationChannelName,
        description: kAiccNotificationChannelDesc,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      ),
    );
  }

  static Future<void> _ensureLocalPlugin() async {
    if (_localPluginReady) return;
    const androidInit = AndroidInitializationSettings('@drawable/ic_stat_notification');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _localPlugin.initialize(
      const InitializationSettings(android: androidInit, iOS: darwinInit),
      onDidReceiveNotificationResponse: (response) {
        final payload = PushNotificationPayload.tryParse(response.payload);
        if (payload != null) {
          PushNotificationNavigator.open(payload);
        }
      },
      onDidReceiveBackgroundNotificationResponse: _onLocalNotificationBackgroundTap,
    );
    _localPluginReady = true;
  }

  Future<void> _configureIosPresentation() async {
    if (kIsWeb || !Platform.isIOS) return;
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: true,
    );
  }

  Future<void> _requestPermissionGracefully() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );
      debugPrint('Notification permission: ${settings.authorizationStatus}');

      if (!kIsWeb && Platform.isAndroid) {
        final android = _localPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        await android?.requestNotificationsPermission();
      }
    } catch (e) {
      debugPrint('Notification permission request failed: $e');
    }
  }

  void _bindForegroundListeners() {
    _onMessageSub?.cancel();
    _onOpenedSub?.cancel();
    _tokenSub?.cancel();

    _onMessageSub = FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    _onOpenedSub =
        FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);
    // Re-register refreshed token with the backend automatically
    _tokenSub = FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      debugPrint('FCM token refreshed (${token.length} chars). Re-registering with backend.');
      _sendTokenToBackend(token);
    });
  }

  Future<void> _handleLaunchMessages() async {
    if (_handlingLaunch) return;
    _handlingLaunch = true;
    try {
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) {
        PushNotificationNavigator.open(
          PushNotificationPayload.fromRemoteMessage(initial),
        );
        return;
      }

      await _ensureLocalPlugin();
      final launch = await _localPlugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp == true) {
        final payload = PushNotificationPayload.tryParse(
          launch?.notificationResponse?.payload,
        );
        if (payload != null) {
          PushNotificationNavigator.open(payload);
        }
      }
    } catch (e) {
      debugPrint('Launch notification handling failed: $e');
    }
  }

  Future<void> _consumePendingLaunch() async {
    PushNotificationNavigator.markRouterReady();
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final payload = PushNotificationPayload.fromRemoteMessage(message);
    if (!_remember(payload.dedupeKey)) return;

    _refreshInbox();
    if (!_foregroundController.isClosed) {
      _foregroundController.add(payload);
    }
    // Android does not show FCM notification payloads while the app is in
    // the foreground; a high-importance local notification is the heads-up.
    if (!kIsWeb && Platform.isAndroid) {
      await displayLocalNotification(payload);
    }
  }

  Future<void> _onMessageOpened(RemoteMessage message) async {
    final payload = PushNotificationPayload.fromRemoteMessage(message);
    _refreshInbox();
    PushNotificationNavigator.open(payload);
  }

  static void _refreshInbox() {
    try {
      if (sl.isRegistered<NotificationsProvider>()) {
        sl<NotificationsProvider>().onPushReceived();
      }
    } catch (_) {}
  }

  bool _remember(String key) {
    if (key.isEmpty) return true;
    if (_recentKeys.contains(key)) return false;
    _recentKeys.add(key);
    if (_recentKeys.length > 50) {
      _recentKeys.remove(_recentKeys.first);
    }
    return true;
  }

  /// Fetches the current FCM token and registers it with the backend.
  /// Only runs when the user is logged in (has a JWT token).
  Future<void> _registerTokenWithBackend() async {
    if (kIsWeb) return;
    if (!LocalStorage.instance.hasToken()) {
      debugPrint('FCM token registration skipped: user not logged in.');
      return;
    }
    try {
      if (!kIsWeb && Platform.isIOS) {
        final apns = await FirebaseMessaging.instance.getAPNSToken();
        if (apns == null) {
          debugPrint('APNS token not ready yet; FCM token registration will retry on refresh.');
          return;
        }
      }
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('FCM token unavailable (permission denied or unsupported platform).');
        return;
      }
      debugPrint('FCM token acquired (${token.length} chars). Registering with backend...');
      await _sendTokenToBackend(token);
    } catch (e) {
      debugPrint('FCM token registration failed: $e');
    }
  }

  /// POSTs the FCM device token to the backend so it can target push notifications.
  static Future<void> _sendTokenToBackend(String token) async {
    try {
      final client = sl<DioClient>();
      await client.post(
        ApiEndpoints.fcmToken,
        data: {'token': token},
      );
      debugPrint('FCM token registered with backend successfully.');
    } on DioException catch (e) {
      // 401 = user not logged in yet; silently ignore and retry on next login
      if (e.response?.statusCode == 401) {
        debugPrint('FCM token backend registration skipped: not authenticated.');
        return;
      }
      debugPrint('FCM token backend registration failed: ${e.message}');
    } catch (e) {
      debugPrint('FCM token backend registration error: $e');
    }
  }

  /// Calls DELETE /notifications/fcm-token on the backend to deregister.
  static Future<void> _clearTokenFromBackend() async {
    try {
      final client = sl<DioClient>();
      await client.delete(ApiEndpoints.fcmToken);
      debugPrint('FCM token cleared from backend successfully.');
    } catch (e) {
      debugPrint('FCM token backend clear failed (non-critical): $e');
    }
  }

  static Future<void> displayLocalNotification(
    PushNotificationPayload payload,
  ) async {
    try {
      await _ensureLocalPlugin();
      final id = payload.dedupeKey.hashCode & 0x7fffffff;
      await _localPlugin.show(
        id == 0 ? DateTime.now().millisecondsSinceEpoch.remainder(100000) : id,
        payload.actorName?.isNotEmpty == true ? payload.actorName : payload.title,
        payload.body.isNotEmpty ? payload.body : payload.title,
        NotificationDetails(
          android: AndroidNotificationDetails(
            kAiccNotificationChannelId,
            kAiccNotificationChannelName,
            channelDescription: kAiccNotificationChannelDesc,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@drawable/ic_stat_notification',
            color: const Color(0xFFDC8B20), // AppColors.primary
            styleInformation: BigTextStyleInformation(
              payload.body.isNotEmpty ? payload.body : payload.title,
              contentTitle: payload.actorName?.isNotEmpty == true
                  ? payload.actorName
                  : payload.title,
            ),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload.toPayloadString(),
      );
    } catch (e) {
      debugPrint('Local notification display failed: $e');
    }
  }
}
