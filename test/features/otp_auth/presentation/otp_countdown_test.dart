import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── Countdown timer logic ───────────────────────────────────────
  // These tests mirror OtpScreen._startTimer / _left behaviour.

  group('OTP resend countdown', () {
    test('countdown reaches 0 after N ticks', () async {
      int left = 3;
      final completer = Completer<void>();

      // Use a fast 10ms tick to keep tests quick
      final timer = Timer.periodic(const Duration(milliseconds: 10), (t) {
        left = left > 0 ? left - 1 : 0;
        if (left == 0) {
          t.cancel();
          if (!completer.isCompleted) completer.complete();
        }
      });

      await completer.future;
      timer.cancel();
      expect(left, 0);
    });

    test('resend is enabled only when left == 0', () {
      bool canResend(int left) => left == 0;
      expect(canResend(0), isTrue);
      expect(canResend(1), isFalse);
      expect(canResend(30), isFalse);
      expect(canResend(59), isFalse);
    });

    test('label shows countdown when left > 0', () {
      String label(int left) =>
          left == 0 ? 'Resend OTP' : 'Resend OTP in ${left}s';
      expect(label(0), 'Resend OTP');
      expect(label(30), 'Resend OTP in 30s');
      expect(label(1), 'Resend OTP in 1s');
    });

    test('label shows plain text when left == 0', () {
      String label(int left) =>
          left == 0 ? 'Resend OTP' : 'Resend OTP in ${left}s';
      expect(label(0), 'Resend OTP');
    });

    test('new timer replaces old one (simulate resend)', () async {
      int left = 2;
      Timer? timer;

      void startTimer(int s) {
        timer?.cancel();
        left = s;
        timer = Timer.periodic(const Duration(milliseconds: 10), (t) {
          left = left > 0 ? left - 1 : 0;
          if (left == 0) t.cancel();
        });
      }

      // Start at 2, then resend with 3 before it finishes
      startTimer(2);
      await Future.delayed(const Duration(milliseconds: 15));
      startTimer(3); // reset to 3
      expect(left, 3);
      timer?.cancel();
    });
  });

  // ── Masked phone number display ─────────────────────────────────

  group('Masked phone number', () {
    String masked(String phone) => '+91 ****${phone.substring(6)}';

    test('shows last 4 digits of a 10-digit number', () {
      expect(masked('9876543210'), '+91 ****3210');
    });

    test('shows last 4 digits for another number', () {
      expect(masked('6000001234'), '+91 ****1234');
    });

    test('prefix is always +91 ****', () {
      expect(masked('9999999999').startsWith('+91 ****'), isTrue);
    });
  });

  // ── OTP input gate ──────────────────────────────────────────────

  group('OTP verification gate', () {
    test('verify is blocked when otp length != 6', () {
      bool shouldVerify(bool busy, String otp) =>
          !busy && otp.length == 6;
      expect(shouldVerify(false, '12345'), isFalse);
      expect(shouldVerify(false, '1234567'), isFalse);
      expect(shouldVerify(false, ''), isFalse);
      expect(shouldVerify(false, '123456'), isTrue);
    });

    test('verify is blocked when busy', () {
      bool shouldVerify(bool busy, String otp) =>
          !busy && otp.length == 6;
      expect(shouldVerify(true, '123456'), isFalse);
    });
  });
}

