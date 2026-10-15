import 'dart:async';
import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:play_install_referrer/play_install_referrer.dart';
import 'package:share_plus/share_plus.dart';

import '../routes/app_router.dart';
import '../routes/app_routes.dart';
import '../storage/local_storage.dart';

/// 100% Free Native Deep Linking & Deferred Install Referrer Service for TreeKo.
///
/// Features:
/// 1. Installed App: Opens app directly via TreeKo URI scheme (treeko://) & App Links.
/// 2. Not-Installed App (Deferred): Links to Google Play Store with referrer=profile_id%3D<id>.
///    Upon first launch post-install, reads referrer and opens that shared profile!
/// 3. Sign-in Required Flow: Caches pending profile ID until user logs in or registers.
/// 4. Zero recurring cost, no credit cards, no third-party server dependency.
class DeepLinkService {
  static final DeepLinkService instance = DeepLinkService._internal();
  DeepLinkService._internal();

  static const String playStoreBaseUrl =
      'https://play.google.com/store/apps/details?id=talentcasting.com';

  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _appLinksSub;
  bool _isInitialized = false;

  /// Initializes deep link listeners and checks Play Store install referrer on first run.
  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      _appLinks = AppLinks();

      // 1. Check for initial link if cold-launched from link
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint('🌿 [DeepLink] Initial URI: $initialUri');
        _handleIncomingUri(initialUri);
      }

      // 2. Listen to incoming links while running in foreground / background
      _appLinksSub = _appLinks.uriLinkStream.listen(
        (uri) {
          debugPrint('🌿 [DeepLink] Received URI: $uri');
          _handleIncomingUri(uri);
        },
        onError: (err) {
          debugPrint('⚠️ [DeepLink] Stream error: $err');
        },
      );
    } catch (e) {
      debugPrint('⚠️ [DeepLink] AppLinks init error: $e');
    }

    // 3. Deferred Deep Linking via Google Play Install Referrer (Android only)
    await _checkGooglePlayInstallReferrer();
  }

  /// Checks Google Play Store install referrer on first run after installation.
  Future<void> _checkGooglePlayInstallReferrer() async {
    if (kIsWeb || !Platform.isAndroid) return;

    try {
      final alreadyChecked = LocalStorage.instance.hasCheckedInstallReferrer();
      if (alreadyChecked) return;

      debugPrint('🌿 [DeepLink] Checking Google Play Install Referrer...');
      final referrerDetails = await PlayInstallReferrer.installReferrer;
      final rawReferrer = referrerDetails.installReferrer;

      await LocalStorage.instance.setHasCheckedInstallReferrer(true);

      if (rawReferrer != null && rawReferrer.isNotEmpty) {
        debugPrint('🌿 [DeepLink] Play Store install referrer: $rawReferrer');
        _parseAndRouteReferrer(rawReferrer);
      }
    } catch (e) {
      debugPrint('ℹ️ [DeepLink] Play Install Referrer check completed: $e');
      // Mark checked to prevent retrying repeatedly on non-Play store debug builds
      await LocalStorage.instance.setHasCheckedInstallReferrer(true);
    }
  }

  /// Parses referrer string (e.g. "profile_id=123" or "utm_source=...&profile_id=123")
  void _parseAndRouteReferrer(String referrer) {
    try {
      String? profileId;

      // Unescape if needed
      final decoded = Uri.decodeComponent(referrer);

      // Parse query string parameters
      final parsedUri = Uri.tryParse('treeko://dummy?$decoded') ??
          Uri.tryParse('treeko://dummy?$referrer');

      if (parsedUri != null) {
        profileId = parsedUri.queryParameters['profile_id'] ??
            parsedUri.queryParameters['profileId'] ??
            parsedUri.queryParameters['id'] ??
            parsedUri.queryParameters['userId'];
      }

      // Regex fallback
      if (profileId == null || profileId.isEmpty) {
        final match = RegExp(r'(?:profile_id|profileId|id|userId)=([^&]+)')
            .firstMatch(decoded);
        if (match != null) {
          profileId = match.group(1);
        }
      }

      if (profileId != null && profileId.trim().isNotEmpty) {
        debugPrint('🌿 [DeepLink] Found deferred profile ID from Play Store: $profileId');
        _routeToProfile(profileId.trim());
      }
    } catch (e) {
      debugPrint('⚠️ [DeepLink] Error parsing referrer: $e');
    }
  }

  /// Handles incoming URIs from App Links or Custom Schemes (treeko://, https://...)
  void _handleIncomingUri(Uri uri) {
    try {
      String? profileId;

      // 1. Check query parameters (?id=... or ?profile_id=...)
      profileId = uri.queryParameters['profile_id'] ??
          uri.queryParameters['profileId'] ??
          uri.queryParameters['id'] ??
          uri.queryParameters['userId'];

      // 2. Check path segments (/profile/123 or /users/123)
      if (profileId == null || profileId.isEmpty) {
        final segments = uri.pathSegments;
        if (segments.length >= 2 &&
            (segments[0] == 'profile' || segments[0] == 'users')) {
          profileId = segments[1];
        } else if (segments.isNotEmpty &&
            (uri.host == 'profile' || uri.host == 'users')) {
          profileId = segments[0];
        }
      }

      // 3. Check referrer in play.google.com URL
      if (profileId == null && uri.queryParameters.containsKey('referrer')) {
        final ref = uri.queryParameters['referrer'];
        if (ref != null) {
          _parseAndRouteReferrer(ref);
          return;
        }
      }

      if (profileId != null && profileId.trim().isNotEmpty) {
        debugPrint('🌿 [DeepLink] Resolved profile ID from URI: $profileId');
        _routeToProfile(profileId.trim());
      }
    } catch (e) {
      debugPrint('⚠️ [DeepLink] Error handling incoming URI: $e');
    }
  }

  /// Routes to the shared profile or stores it if sign-in is required first.
  void _routeToProfile(String profileId) {
    final cleanId = profileId.trim();
    if (cleanId.isEmpty) return;

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

  /// Checks and navigates to any pending deferred profile after sign-in.
  /// Called after successful login, signup, or home screen loading.
  Future<bool> handlePendingProfileIfAny(BuildContext context) async {
    try {
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
      debugPrint('⚠️ Error processing pending profile link: $e');
    }
    return false;
  }

  /// Creates the 100% free shareable Play Store link carrying the profile ID.
  String createProfileShareLink({
    required String profileId,
    required String name,
    String? role,
    String? imageUrl,
  }) {
    final cleanId = profileId.trim();
    final encodedReferrer = Uri.encodeComponent('profile_id=$cleanId');
    return '$playStoreBaseUrl&referrer=$encodedReferrer';
  }

  /// Complete share action: triggers the native OS share sheet.
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

    final link = createProfileShareLink(
      profileId: cleanId,
      name: name,
      role: role,
      imageUrl: imageUrl,
    );

    final displayName = name.trim().isEmpty ? 'Artist' : name.trim();
    final roleText = (role != null && role.isNotEmpty) ? ' ($role)' : '';

    final text =
        "Check out $displayName's$roleText profile on TreeKo! 🎬\n"
        "Discover their portfolio, auditions, and creative work:\n$link";

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
