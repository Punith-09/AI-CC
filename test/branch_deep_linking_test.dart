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
    test('createProfileShareLink generates Google Play Store link carrying profile_id in referrer', () {
      final service = DeepLinkService.instance;
      const testProfileId = 'user-artist-12345';
      const testName = 'John Director';

      final link = service.createProfileShareLink(
        profileId: testProfileId,
        name: testName,
        role: 'Director',
      );

      expect(link, isNotEmpty);
      expect(link, contains('play.google.com/store/apps/details?id=talentcasting.com'));
      expect(link, contains('referrer=profile_id%3Duser-artist-12345'));
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
  });
}
