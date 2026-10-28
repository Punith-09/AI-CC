import 'dart:async';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../routes/app_router.dart';
import '../routes/app_routes.dart';
import '../storage/local_storage.dart';

/// AppsFlyer OneLink & Deferred Deep Linking Service for TreeKo.
///
/// Features:
/// 1. Installed App: Opens app directly to the user profile via OneLink / App Links / URI scheme.
/// 2. Not-Installed App (Deferred): OneLink redirects user to Google Play Store.
///    Upon first launch post-install, AppsFlyer UDL (Unified Deep Linking) attributes the click
///    and provides the shared profile ID!
/// 3. Sign-in Required Flow: Caches pending profile ID in LocalStorage until user logs in or registers,
///    then automatically routes to that profile.
/// 4. 100% Free: No credit card required (AppsFlyer Zero plan).
class DeepLinkService {
  static final DeepLinkService instance = DeepLinkService._internal();
  DeepLinkService._internal();

  static const String devKey = 'Cs5tpqMqrWinzdH7zGg3FR';
  static const String appId = 'talentcasting.com';
  static const String playStoreBaseUrl =
      'https://play.google.com/store/apps/details?id=talentcasting.com';

  /// OneLink template ID from AppsFlyer dashboard.
  static String oneLinkTemplateId = 'CEaN';
  static String oneLinkDomain = 'treeko.onelink.me';

  late final AppsFlyerSdk _appsflyer;
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _appLinksSub;
  bool _isInitialized = false;

  String? _lastRoutedProfileId;
  DateTime? _lastRoutedTime;
  String? _lastIncomingUriString;

  /// Initializes AppsFlyer and AppLinks listeners.
  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      _appsflyer = AppsFlyerSdk.instance;

      // 1. MUST register deep link listener BEFORE init() for UDL
      await _appsflyer.registerDeepLinkListener(
        onDeepLinking: (DeepLinkResult result) async {
          debugPrint('🌿 [AppsFlyer UDL] DeepLinkResult: $result');
          if (result.status == DeepLinkStatus.found && result.deepLink != null) {
            final deepLink = result.deepLink!;

            // If deferred install: only process ONCE in the app's lifetime
            if (deepLink.isDeferred == true) {
              if (LocalStorage.instance.hasProcessedDeferredInstall()) {
                debugPrint('🌿 [AppsFlyer UDL] Deferred install already processed. Skipping.');
                return;
              }
              await LocalStorage.instance.setHasProcessedDeferredInstall(true);
            }

            final payload = deepLink.deepLinkValue ??
                deepLink.getStringValue('profile_id') ??
                deepLink.getStringValue('id') ??
                deepLink.afSub1;

            final token = deepLink.getStringValue('token') ??
                deepLink.getStringValue('deep_link_sub1') ??
                deepLink.getStringValue('deep_link_sub2') ??
                deepLink.getStringValue('otp') ??
                deepLink.afSub1 ??
                deepLink.afSub2;
            final email = deepLink.getStringValue('email') ??
                deepLink.getStringValue('deep_link_sub2') ??
                deepLink.getStringValue('deep_link_sub3') ??
                deepLink.afSub3;

            debugPrint('🌿 [AppsFlyer UDL] Found payload: $payload, token: $token (isDeferred: ${deepLink.isDeferred})');
            if (payload != null && payload.isNotEmpty) {
              _routeDestination(payload, token: token, email: email);
            } else if (token != null && token.isNotEmpty) {
              _routeToResetPassword(token: token, email: email);
            }
          }
        },
      );

      // 2. Initialize AppsFlyer SDK
      await _appsflyer.init(
        devKey: devKey,
        appId: appId,
      );

      // 3. Register conversion listener (fallback for install attribution)
      await _appsflyer.registerConversionListener(
        onConversionDataSuccess: (Map<String, dynamic> data) async {
          debugPrint('🌿 [AppsFlyer GCD] Conversion data: $data');

          // Conversion data is cached by AppsFlyer and emitted on EVERY app launch.
          // Only process on the very FIRST launch and if not already handled!
          final isFirstLaunch = data['is_first_launch'] == true ||
              data['is_first_launch'] == 'true' ||
              data['is_first_launch'] == 1;

          if (!isFirstLaunch || LocalStorage.instance.hasProcessedDeferredInstall()) {
            debugPrint('🌿 [AppsFlyer GCD] Skipping: isFirstLaunch=$isFirstLaunch, alreadyProcessed=${LocalStorage.instance.hasProcessedDeferredInstall()}');
            return;
          }

          await LocalStorage.instance.setHasProcessedDeferredInstall(true);

          final payload = data['deep_link_value']?.toString() ??
              data['profile_id']?.toString() ??
              data['id']?.toString() ??
              data['af_sub1']?.toString();

          final token = data['token']?.toString() ??
              data['deep_link_sub1']?.toString() ??
              data['deep_link_sub2']?.toString() ??
              data['otp']?.toString() ??
              data['af_sub1']?.toString() ??
              data['af_sub2']?.toString();
          final email = data['email']?.toString() ??
              data['deep_link_sub2']?.toString() ??
              data['deep_link_sub3']?.toString() ??
              data['af_sub3']?.toString();

          if (payload != null && payload.isNotEmpty) {
            _routeDestination(payload, token: token, email: email);
          } else if (token != null && token.isNotEmpty) {
            _routeToResetPassword(token: token, email: email);
          }
        },
        onConversionDataFail: (Map<String, dynamic> error) {
          debugPrint('⚠️ [AppsFlyer GCD] Conversion error: $error');
        },
      );

      // 4. Register session-ready listener & start SDK
      await _appsflyer.registerSessionReadyListener(() async {
        debugPrint('🌿 [AppsFlyer] Session ready, starting SDK...');
        await _appsflyer.start();
      });

      // 5. Configure OneLink ID if available
      if (oneLinkTemplateId.isNotEmpty) {
        await _appsflyer.setAppInviteOneLink(oneLinkTemplateId);
      }
    } catch (e) {
      debugPrint('⚠️ [AppsFlyer] Init error: $e');
    }

    // 6. Native AppLinks listener fallback (direct treeko:// & https links)
    try {
      _appLinks = AppLinks();
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint('🌿 [AppLinks] Initial URI: $initialUri');
        _handleIncomingUri(initialUri);
      }

      _appLinksSub = _appLinks.uriLinkStream.listen(
            (uri) {
          debugPrint('🌿 [AppLinks] Incoming URI: $uri');
          _handleIncomingUri(uri);
        },
        onError: (err) {
          debugPrint('⚠️ [AppLinks] Stream error: $err');
        },
      );
    } catch (e) {
      debugPrint('⚠️ [AppLinks] Init error: $e');
    }
  }

  /// Sets the OneLink template ID and domain dynamically
  Future<void> configureOneLink({
    required String templateId,
    String? domain,
  }) async {
    oneLinkTemplateId = templateId.trim();
    if (domain != null && domain.trim().isNotEmpty) {
      oneLinkDomain = domain.trim();
    }
    if (_isInitialized && oneLinkTemplateId.isNotEmpty) {
      try {
        await _appsflyer.setAppInviteOneLink(oneLinkTemplateId);
      } catch (e) {
        debugPrint('⚠️ [AppsFlyer] Error setting OneLink ID: $e');
      }
    }
  }

  /// Handles incoming URIs from App Links or Custom Schemes (treeko://, https://...)
  void _handleIncomingUri(Uri uri) {
    try {
      final uriString = uri.toString();
      if (_lastIncomingUriString == uriString &&
          _lastRoutedTime != null &&
          DateTime.now().difference(_lastRoutedTime!).inSeconds < 5) {
        debugPrint('🌿 [DeepLink] Skipping duplicate incoming URI: $uriString');
        return;
      }
      _lastIncomingUriString = uriString;

      // Check if URI specifically points to delete account
      final uriLower = uri.toString().toLowerCase();
      if (uriLower.contains('delete_account') ||
          uriLower.contains('deleteaccount') ||
          uriLower.contains('delete-account') ||
          (uri.scheme == 'treeko' && uri.host.toLowerCase().contains('delete'))) {
        debugPrint('🌿 [DeepLink] Resolved Delete Account route from URI');
        _routeToDeleteAccount();
        return;
      }

      // Check if URI specifically points to reset password
      if (uriLower.contains('reset_password') ||
          uriLower.contains('resetpassword') ||
          uriLower.contains('reset-password') ||
          uriLower.contains('forgotpassword') ||
          uriLower.contains('forgot-password') ||
          (uri.scheme == 'treeko' && uri.host.toLowerCase().contains('forgot'))) {
        final token = uri.queryParameters['token'] ??
            uri.queryParameters['deep_link_sub1'] ??
            uri.queryParameters['deep_link_sub2'] ??
            uri.queryParameters['otp'];
        final email = uri.queryParameters['email'] ??
            uri.queryParameters['deep_link_sub2'] ??
            uri.queryParameters['deep_link_sub3'];
        debugPrint('🌿 [DeepLink] Resolved Reset Password route from URI with token: $token');
        _routeToResetPassword(token: token, email: email);
        return;
      }

      String? payload;
      final token = uri.queryParameters['token'] ??
          uri.queryParameters['deep_link_sub1'] ??
          uri.queryParameters['deep_link_sub2'] ??
          uri.queryParameters['otp'];
      final email = uri.queryParameters['email'] ??
          uri.queryParameters['deep_link_sub2'] ??
          uri.queryParameters['deep_link_sub3'];

      // 1. Query parameters (?id=... or ?profile_id=... or ?deep_link_value=...)
      payload = uri.queryParameters['deep_link_value'] ??
          uri.queryParameters['profile_id'] ??
          uri.queryParameters['profileId'] ??
          uri.queryParameters['id'] ??
          uri.queryParameters['userId'] ??
          uri.queryParameters['af_sub1'];

      // 2. Path segments (/profile/123 or /users/123 or /deleteAccount)
      if (payload == null || payload.isEmpty) {
        final segments = uri.pathSegments;
        if (segments.length >= 2 &&
            (segments[0] == 'profile' || segments[0] == 'users')) {
          payload = segments[1];
        } else if (segments.isNotEmpty &&
            (uri.host == 'profile' || uri.host == 'users')) {
          payload = segments[0];
        }
      }

      // 3. Fallback if host itself is payload (e.g. treeko://670e1234)
      if (payload == null || payload.isEmpty) {
        if (uri.scheme == 'treeko' &&
            uri.host.isNotEmpty &&
            uri.host != 'open' &&
            uri.host != 'profile' &&
            uri.host != 'users') {
          payload = uri.host;
        }
      }

      if (payload != null && payload.trim().isNotEmpty) {
        debugPrint('🌿 [DeepLink] Resolved payload from URI: $payload');
        _routeDestination(payload.trim(), token: token, email: email);
      } else if (token != null && token.trim().isNotEmpty) {
        _routeToResetPassword(token: token.trim(), email: email?.trim());
      }
    } catch (e) {
      debugPrint('⚠️ [DeepLink] Error handling incoming URI: $e');
    }
  }

  /// Routes to the intended deep link destination (Profile, Delete Account, Reset Password, etc.)
  void _routeDestination(String destination, {String? token, String? email}) {
    final clean = destination.trim();
    if (clean.isEmpty) return;

    final lower = clean.toLowerCase();
    if (lower == 'delete_account' ||
        lower == 'deleteaccount' ||
        lower == 'delete-account' ||
        lower == 'delete') {
      _routeToDeleteAccount();
      return;
    }

    if (lower == 'reset_password' ||
        lower == 'resetpassword' ||
        lower == 'reset-password' ||
        lower == 'forgotpassword' ||
        lower == 'forgot_password') {
      _routeToResetPassword(token: token, email: email);
      return;
    }

    // Default: artist profile ID
    _routeToProfile(clean);
  }

  /// Routes to the Forgot / Reset Password screen with token and optional email.
  void _routeToResetPassword({String? token, String? email}) {
    final cleanToken = token?.trim();
    final cleanEmail = email?.trim();
    final cacheKey = 'reset_password_${cleanToken ?? ''}';

    if (_lastRoutedProfileId == cacheKey &&
        _lastRoutedTime != null &&
        DateTime.now().difference(_lastRoutedTime!).inSeconds < 5) {
      debugPrint('🌿 [DeepLink] Skipping duplicate reset_password route');
      return;
    }
    _lastRoutedProfileId = cacheKey;
    _lastRoutedTime = DateTime.now();

    final query = <String, String>{};
    if (cleanToken != null && cleanToken.isNotEmpty) query['token'] = cleanToken;
    if (cleanEmail != null && cleanEmail.isNotEmpty) query['email'] = cleanEmail;

    final uri = Uri(
      path: AppRoutes.forgotPassword,
      queryParameters: query.isEmpty ? null : query,
    ).toString();

    debugPrint('🌿 [DeepLink] Routing to reset password screen: $uri');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        appRouter.push(uri);
      } catch (e) {
        debugPrint('⚠️ Failed to route to reset password: $e');
      }
    });
  }

  /// Routes to the Delete Account screen or saves it as a deferred destination.
  void _routeToDeleteAccount() {
    if (_lastRoutedProfileId == 'delete_account' &&
        _lastRoutedTime != null &&
        DateTime.now().difference(_lastRoutedTime!).inSeconds < 5) {
      debugPrint('🌿 [DeepLink] Skipping duplicate delete_account route');
      return;
    }
    _lastRoutedProfileId = 'delete_account';
    _lastRoutedTime = DateTime.now();

    final bool isLoggedIn = LocalStorage.instance.hasToken();

    if (isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          appRouter.push(AppRoutes.deleteAccount);
        } catch (e) {
          debugPrint('⚠️ Failed to route to delete account: $e');
        }
      });
    } else {
      debugPrint('🌿 User not signed in. Storing pending route: ${AppRoutes.deleteAccount}');
      LocalStorage.instance.savePendingRoute(AppRoutes.deleteAccount);
    }
  }

  /// Routes to the shared profile or stores it if sign-in is required first.
  void _routeToProfile(String profileId) {
    final cleanId = profileId.trim();
    if (cleanId.isEmpty) return;

    // Avoid double routing to the same profile within 5 seconds
    if (_lastRoutedProfileId == cleanId &&
        _lastRoutedTime != null &&
        DateTime.now().difference(_lastRoutedTime!).inSeconds < 5) {
      debugPrint('🌿 [DeepLink] Skipping duplicate profile route: $cleanId');
      return;
    }
    _lastRoutedProfileId = cleanId;
    _lastRoutedTime = DateTime.now();

    final bool isLoggedIn = LocalStorage.instance.hasToken();

    if (isLoggedIn) {
      // User is already signed in -> navigate directly to profile
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          appRouter.push(AppRoutes.exploreProfile, extra: cleanId);
        } catch (e) {
          debugPrint('⚠️ Failed to route to profile: $e');
        }
      });
    } else {
      // User needs to sign in first -> save as deferred destination
      debugPrint('🌿 User not signed in. Storing pending profile ID: $cleanId');
      LocalStorage.instance.savePendingProfileId(cleanId);
    }
  }

  /// Checks and navigates to any pending deferred destination (Delete Account or Profile) after sign-in.
  /// Called after successful login, signup, or home screen loading.
  Future<bool> handlePendingProfileIfAny(BuildContext context) async {
    try {
      // 1. Check pending route (e.g. Delete Account)
      final pendingRoute = LocalStorage.instance.getPendingRoute();
      if (pendingRoute != null && pendingRoute.trim().isNotEmpty) {
        await LocalStorage.instance.clearPendingRoute();
        debugPrint('🌿 Resuming deferred deep link to route: $pendingRoute');

        if (context.mounted) {
          if (pendingRoute == AppRoutes.deleteAccount) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('Continuing to Account Deletion...'),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF1E293B),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }

          appRouter.push(pendingRoute.trim());
          return true;
        }
      }

      // 2. Check pending profile
      final pendingId = LocalStorage.instance.getPendingProfileId();
      if (pendingId != null && pendingId.trim().isNotEmpty) {
        await LocalStorage.instance.clearPendingProfileId();
        debugPrint('🌿 Resuming deferred deep link to profile: $pendingId');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.person_pin_circle_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Continuing to shared profile...'),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF1E293B),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );

          appRouter.push(AppRoutes.exploreProfile, extra: pendingId.trim());
          return true;
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error processing pending link: $e');
    }
    return false;
  }

  /// Creates a shareable OneLink URL carrying the profile ID.
  Future<String> createProfileShareLink({
    required String profileId,
    required String name,
    String? role,
    String? imageUrl,
  }) async {
    final cleanId = profileId.trim();

    // Always generate full OneLink URL carrying explicit parameters & af_dp scheme
    if (oneLinkTemplateId.isNotEmpty) {
      final query = Uri(
        queryParameters: {
          'deep_link_value': cleanId,
          'profile_id': cleanId,
          'af_sub1': name,
          'af_dp': 'treeko://profile?id=$cleanId',
          'af_web_dp': playStoreBaseUrl,
        },
      ).query;
      return 'https://$oneLinkDomain/$oneLinkTemplateId?$query';
    }

    // 3. Fallback to Play Store referrer URL until template is created
    final encodedReferrer = Uri.encodeComponent('profile_id=$cleanId');
    return '$playStoreBaseUrl&referrer=$encodedReferrer';
  }

  /// Creates the static OneLink URL for Delete Account navigation.
  String createDeleteAccountLink() {
    final query = Uri(
      queryParameters: {
        'deep_link_value': 'delete_account',
        'af_dp': 'treeko://deleteAccount',
        'af_web_dp': playStoreBaseUrl,
      },
    ).query;
    return 'https://$oneLinkDomain/$oneLinkTemplateId?$query';
  }

  /// Creates the OneLink URL for Password Reset carrying the token.
  String createResetPasswordLink({
    required String token,
    String? email,
  }) {
    final cleanToken = token.trim();
    final query = Uri(
      queryParameters: {
        'deep_link_value': 'reset_password',
        'token': cleanToken,
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        'af_dp': 'treeko://forgotPassword?token=$cleanToken',
        'af_web_dp': 'https://casting-be-1.onrender.com/auth/reset-password?token=$cleanToken',
      },
    ).query;
    return 'https://$oneLinkDomain/$oneLinkTemplateId?$query';
  }

  /// Complete share action: triggers the native OS share sheet with a single clickable link!
  Future<void> shareProfile({
    required BuildContext context,
    required String profileId,
    required String name,
    String? role,
    String? imageUrl,
  }) async {
    final cleanId = profileId.trim();
    if (cleanId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot share profile: missing profile ID')),
      );
      return;
    }

    final shareUrl = await createProfileShareLink(
      profileId: cleanId,
      name: name,
      role: role,
      imageUrl: imageUrl,
    );

    final displayName = name.trim().isEmpty ? 'Artist' : name.trim();
    final roleText = (role != null && role.isNotEmpty) ? ' ($role)' : '';

    final text =
        "Check out $displayName's$roleText profile on TreeKo! 🎬\n\n"
        "$shareUrl";

    await Share.share(
      text,
      subject: "Check out $displayName on TreeKo",
    );
  }

  void dispose() {
    _appLinksSub?.cancel();
  }
}

/// Backward compatibility alias so existing BranchService calls seamlessly work.
typedef BranchService = DeepLinkService;
