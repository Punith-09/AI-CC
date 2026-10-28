import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aicc/core/storage/local_storage.dart';
import 'package:aicc/core/services/deep_link_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorage.init();
    await LocalStorage.instance.clearAll();
    await LocalStorage.instance.clearPendingProfileId();
  });

  group('Native Deferred Deep Linking Flow Tests (100% Free)', () {
    test('createProfileShareLink generates link carrying profile_id', () async {
      final service = DeepLinkService.instance;
      const testProfileId = 'user-artist-12345';
      const testName = 'John Director';

      final link = await service.createProfileShareLink(
        profileId: testProfileId,
        name: testName,
        role: 'Director',
      );

      expect(link, isNotEmpty);
      expect(link, contains('treeko.onelink.me/CEaN'));
      expect(link, contains('deep_link_value=user-artist-12345'));
    });

    test('Not-installed / Unauthenticated flow: Pending profile ID is saved to LocalStorage', () async {
      // Simulating user who clicked a link without an active session
      expect(LocalStorage.instance.hasToken(), isFalse);
      expect(LocalStorage.instance.getPendingProfileId(), isNull);

      // Save pending profile ID from incoming link payload
      const testProfileId = 'artist-998877';
      await LocalStorage.instance.savePendingProfileId(testProfileId);

      expect(LocalStorage.instance.getPendingProfileId(), equals(testProfileId));
    });

    test('Sign-in required flow: Completing login clears and consumes the pending profile ID', () async {
      // 1. User taps link before login -> deferred profile is captured
      const sharedProfileId = 'artist-554433';
      await LocalStorage.instance.savePendingProfileId(sharedProfileId);
      expect(LocalStorage.instance.getPendingProfileId(), equals(sharedProfileId));

      // 2. User logs in
      await LocalStorage.instance.saveToken('mock-jwt-token-xyz');
      expect(LocalStorage.instance.hasToken(), isTrue);

      // 3. Deferred deep linking resumes: pending profile is read and cleared
      final pendingToOpen = LocalStorage.instance.getPendingProfileId();
      expect(pendingToOpen, equals(sharedProfileId));

      await LocalStorage.instance.clearPendingProfileId();
      expect(LocalStorage.instance.getPendingProfileId(), isNull);
    });

    test('Installed app / Authenticated flow: Directly recognizes logged-in user', () async {
      // User is already logged in
      await LocalStorage.instance.saveToken('active-token-123');
      expect(LocalStorage.instance.hasToken(), isTrue);

      // When link arrives, it doesn't need to be queued as pending
      expect(LocalStorage.instance.getPendingProfileId(), isNull);
    });

    test('createDeleteAccountLink generates OneLink for delete_account', () {
      final service = DeepLinkService.instance;
      final link = service.createDeleteAccountLink();

      expect(link, isNotEmpty);
      expect(link, contains('treeko.onelink.me/CEaN'));
      expect(link, contains('deep_link_value=delete_account'));
      expect(link, contains('af_dp=treeko%3A%2F%2FdeleteAccount'));
    });

    test('Delete Account flow: pending route is saved when logged out and cleared after login', () async {
      expect(LocalStorage.instance.hasToken(), isFalse);
      expect(LocalStorage.instance.getPendingRoute(), isNull);

      // Simulating incoming delete_account link for unauthenticated user
      await LocalStorage.instance.savePendingRoute('/deleteAccount');
      expect(LocalStorage.instance.getPendingRoute(), equals('/deleteAccount'));

      // User logs in
      await LocalStorage.instance.saveToken('token-abc-123');
      expect(LocalStorage.instance.hasToken(), isTrue);

      // Pending route is consumed
      final pendingRoute = LocalStorage.instance.getPendingRoute();
      expect(pendingRoute, equals('/deleteAccount'));

      await LocalStorage.instance.clearPendingRoute();
      expect(LocalStorage.instance.getPendingRoute(), isNull);
    });

    test('createResetPasswordLink generates OneLink carrying token and email', () {
      final service = DeepLinkService.instance;
      const testToken = 'abc123xyz789token';
      const testEmail = 'user@example.com';

      final link = service.createResetPasswordLink(
        token: testToken,
        email: testEmail,
      );

      expect(link, isNotEmpty);
      expect(link, contains('treeko.onelink.me/CEaN'));
      expect(link, contains('deep_link_value=reset_password'));
      expect(link, contains('token=abc123xyz789token'));
      expect(link, contains('email=user%40example.com'));
      expect(link, contains('af_dp=treeko%3A%2F%2FforgotPassword%3Ftoken%3Dabc123xyz789token'));
      expect(link, contains('af_web_dp=https%3A%2F%2Fcasting-be-1.onrender.com%2Fauth%2Freset-password%3Ftoken%3Dabc123xyz789token'));
    });
  });
}
