import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aicc/features/otp_auth/data/otp_auth_repository.dart';
import 'package:aicc/core/network/dio_client.dart';

// ============================================================
// Fake HTTP adapter – returns a preset status + JSON body
// ============================================================

class _FakeAdapter implements HttpClientAdapter {
  final int statusCode;
  final Map<String, dynamic> body;

  _FakeAdapter({required this.statusCode, required this.body});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final bytes = Uint8List.fromList(utf8.encode(jsonEncode(body)));
    return ResponseBody(
      Stream.value(bytes),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

// ============================================================
// Helper: build an OtpAuthRepository backed by a fake Dio
// ============================================================

OtpAuthRepository _makeRepo({
  required int statusCode,
  required Map<String, dynamic> responseBody,
}) {
  final dioClient = DioClient();
  dioClient.dio.httpClientAdapter =
      _FakeAdapter(statusCode: statusCode, body: responseBody);
  return OtpAuthRepository(dioClient: dioClient);
}

// ============================================================
// TESTS
// ============================================================

void main() {
  // ── OtpApiException.message ─────────────────────────────────────

  group('OtpApiException.message', () {
    test('INVALID_PHONE returns user-friendly message', () {
      final e = OtpApiException('INVALID_PHONE');
      expect(e.message, contains('valid 10-digit'));
    });

    test('INVALID_OTP returns correct message', () {
      final e = OtpApiException('INVALID_OTP');
      expect(e.message, contains('Wrong or expired'));
    });

    test('RATE_LIMITED with retryAfter >=60 shows minutes', () {
      final e = OtpApiException('RATE_LIMITED', retryAfter: 120);
      expect(e.message, contains('2 min'));
    });

    test('RATE_LIMITED with retryAfter <60 shows seconds', () {
      final e = OtpApiException('RATE_LIMITED', retryAfter: 45);
      expect(e.message, contains('45 sec'));
    });

    test('LOCKED with retryAfter shows wait time', () {
      final e = OtpApiException('LOCKED', retryAfter: 300);
      expect(e.message, contains('5 min'));
    });

    test('PHONE_IN_USE returns correct message', () {
      final e = OtpApiException('PHONE_IN_USE');
      expect(e.message, contains('another account'));
    });

    test('ALREADY_EXISTS returns correct message', () {
      final e = OtpApiException('ALREADY_EXISTS');
      expect(e.message, contains('already taken'));
    });

    test('NETWORK returns connection message', () {
      final e = OtpApiException('NETWORK');
      expect(e.message, contains('internet'));
    });

    test('Unknown code returns generic message', () {
      final e = OtpApiException('SOME_UNKNOWN_CODE');
      expect(e.message, contains('went wrong'));
    });
  });

  // ── sendOtp ────────────────────────────────────────────────────

  group('OtpAuthRepository.sendOtp', () {
    test('returns resend_after_seconds on 200', () async {
      final repo = _makeRepo(
        statusCode: 200,
        responseBody: {'success': true, 'resend_after_seconds': 60},
      );
      final seconds = await repo.sendOtp('9876543210');
      expect(seconds, 60);
    });

    test('returns default 30 when resend_after_seconds absent', () async {
      final repo = _makeRepo(
        statusCode: 200,
        responseBody: {'success': true},
      );
      final seconds = await repo.sendOtp('9876543210');
      expect(seconds, 30);
    });

    test('throws OtpApiException INVALID_PHONE on 400', () async {
      final repo = _makeRepo(
        statusCode: 400,
        responseBody: {'error': 'INVALID_PHONE'},
      );
      expect(
        () => repo.sendOtp('12345'),
        throwsA(isA<OtpApiException>()
            .having((e) => e.code, 'code', 'INVALID_PHONE')),
      );
    });

    test('throws OtpApiException RATE_LIMITED on 429 with retryAfter', () async {
      final repo = _makeRepo(
        statusCode: 429,
        responseBody: {'error': 'RATE_LIMITED', 'retry_after': 90},
      );
      await expectLater(
        repo.sendOtp('9876543210'),
        throwsA(isA<OtpApiException>()
            .having((e) => e.code, 'code', 'RATE_LIMITED')
            .having((e) => e.retryAfter, 'retryAfter', 90)),
      );
    });

    test('throws OtpApiException OTP_SEND_FAILED on 502', () async {
      final repo = _makeRepo(
        statusCode: 502,
        responseBody: {'error': 'OTP_SEND_FAILED'},
      );
      expect(
        () => repo.sendOtp('9876543210'),
        throwsA(isA<OtpApiException>()
            .having((e) => e.code, 'code', 'OTP_SEND_FAILED')),
      );
    });
  });

  // ── verifyOtp ──────────────────────────────────────────────────

  group('OtpAuthRepository.verifyOtp', () {
    test('returns needsSignup:true with signupToken when backend says so',
        () async {
      final repo = _makeRepo(
        statusCode: 200,
        responseBody: {
          'needs_signup': true,
          'signup_token': 'signTok999',
        },
      );
      final result = await repo.verifyOtp('9876543210', '000000');
      expect(result.needsSignup, isTrue);
      expect(result.signupToken, 'signTok999');
    });

    test('throws OtpApiException INVALID_OTP on 401', () async {
      final repo = _makeRepo(
        statusCode: 401,
        responseBody: {'error': 'INVALID_OTP'},
      );
      expect(
        () => repo.verifyOtp('9876543210', '000000'),
        throwsA(isA<OtpApiException>()
            .having((e) => e.code, 'code', 'INVALID_OTP')),
      );
    });

    test('throws OtpApiException LOCKED on 423', () async {
      final repo = _makeRepo(
        statusCode: 423,
        responseBody: {'error': 'LOCKED', 'retry_after': 300},
      );
      await expectLater(
        repo.verifyOtp('9876543210', '111111'),
        throwsA(isA<OtpApiException>()
            .having((e) => e.code, 'code', 'LOCKED')
            .having((e) => e.retryAfter, 'retryAfter', 300)),
      );
    });
  });

  // ── resendOtp ──────────────────────────────────────────────────

  group('OtpAuthRepository.resendOtp', () {
    test('returns resend_after_seconds', () async {
      final repo = _makeRepo(
        statusCode: 200,
        responseBody: {'resend_after_seconds': 45},
      );
      final s = await repo.resendOtp('9876543210');
      expect(s, 45);
    });
  });
}

