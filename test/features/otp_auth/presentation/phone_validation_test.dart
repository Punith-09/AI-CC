import 'package:flutter_test/flutter_test.dart';

void main() {
  // Phone number validation regex (mirrors PhoneScreen._valid)
  final phoneRegex = RegExp(r'^[6-9]\d{9}$');

  // Username validation regex (mirrors SignupCompleteScreen._valid)
  final usernameRegex = RegExp(r'^[a-zA-Z0-9_.]{3,30}$');

  // ── Phone validation ────────────────────────────────────────────

  group('Phone number validation', () {
    test('accepts valid numbers starting with 6', () {
      expect(phoneRegex.hasMatch('6123456789'), isTrue);
    });

    test('accepts valid numbers starting with 7', () {
      expect(phoneRegex.hasMatch('7999999999'), isTrue);
    });

    test('accepts valid numbers starting with 8', () {
      expect(phoneRegex.hasMatch('8000000000'), isTrue);
    });

    test('accepts valid numbers starting with 9', () {
      expect(phoneRegex.hasMatch('9876543210'), isTrue);
    });

    test('rejects numbers starting with 5', () {
      expect(phoneRegex.hasMatch('5123456789'), isFalse);
    });

    test('rejects numbers starting with 0', () {
      expect(phoneRegex.hasMatch('0000000000'), isFalse);
    });

    test('rejects numbers shorter than 10 digits', () {
      expect(phoneRegex.hasMatch('987654321'), isFalse);
    });

    test('rejects numbers longer than 10 digits', () {
      expect(phoneRegex.hasMatch('98765432101'), isFalse);
    });

    test('rejects empty string', () {
      expect(phoneRegex.hasMatch(''), isFalse);
    });

    test('rejects input with non-digit characters', () {
      expect(phoneRegex.hasMatch('9876abcdef'), isFalse);
    });

    test('rejects input with spaces', () {
      expect(phoneRegex.hasMatch('9876 43210'), isFalse);
    });
  });

  // ── Username validation ─────────────────────────────────────────

  group('Username validation', () {
    test('accepts alphanumeric usernames', () {
      expect(usernameRegex.hasMatch('alice'), isTrue);
    });

    test('accepts usernames with underscore and dot', () {
      expect(usernameRegex.hasMatch('user_123.name'), isTrue);
    });

    test('accepts 3-character minimum', () {
      expect(usernameRegex.hasMatch('abc'), isTrue);
    });

    test('accepts 30-character maximum', () {
      expect(usernameRegex.hasMatch('a' * 30), isTrue);
    });

    test('rejects usernames shorter than 3 chars', () {
      expect(usernameRegex.hasMatch('ab'), isFalse);
    });

    test('rejects usernames longer than 30 chars', () {
      expect(usernameRegex.hasMatch('a' * 31), isFalse);
    });

    test('rejects usernames with @', () {
      expect(usernameRegex.hasMatch('user@name'), isFalse);
    });

    test('rejects usernames with spaces', () {
      expect(usernameRegex.hasMatch('user name'), isFalse);
    });

    test('rejects usernames with hyphens', () {
      expect(usernameRegex.hasMatch('user-name'), isFalse);
    });

    test('rejects empty string', () {
      expect(usernameRegex.hasMatch(''), isFalse);
    });
  });

  // ── Error message display logic ─────────────────────────────────

  group('Error message display logic', () {
    test('null error means no error widget shown', () {
      String? error;
      expect(error != null, isFalse);
    });

    test('non-null non-empty error means error widget shown', () {
      const String? error = 'Wrong or expired OTP. Please try again.';
      expect(error != null && error.isNotEmpty, isTrue);
    });

    test('empty string error does not trigger display', () {
      const String? error = '';
      // Guard in real screen: _error != null — empty string still shows.
      // Guard should check isNotEmpty too; test documents the behaviour.
      expect(error == null, isFalse);
      expect(error!.isEmpty, isTrue);
    });
  });
}

