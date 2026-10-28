import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../features/notifications/presentation/providers/notifications_provider.dart';
import '../../firebase_options.dart';
import '../di/injection_container.dart';
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
/// Does not send notifications. Device-token upload is skipped until the
/// backend documents a registration endpoint (none exists in this project).
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
    await _logCurrentToken();
  }

  void attachRouter() {
    PushNotificationNavigator.markRouterReady();
  }

  Future<void> onUserSignedIn() async {
    await _requestPermissionGracefully();
    await _logCurrentToken();
    await _consumePendingLaunch();
  }

  Future<void> onUserSignedOut() async {
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
    _tokenSub = FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      debugPrint('FCM token refreshed (${token.length} chars). Backend registration endpoint is not defined in this app.');
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
    await displayLocalNotification(payload);
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

  Future<void> _logCurrentToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('FCM token unavailable (permission denied or unsupported platform).');
        return;
      }
      debugPrint(
        'FCM token acquired (${token.length} chars). '
        'No device-token API exists in this Flutter project; the backend must accept this token before pushes can be targeted.',
      );
    } catch (e) {
      debugPrint('FCM getToken failed: $e');
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
