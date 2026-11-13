import 'package:dio/dio.dart';
import 'package:aicc/core/api/api_endpoints.dart';
import 'package:aicc/core/storage/local_storage.dart';
import 'package:aicc/core/network/dio_client.dart';
import 'package:aicc/core/di/injection_container.dart';

// ============================================================
// EXCEPTIONS
// ============================================================

class OtpApiException implements Exception {
  final String code;
  final int? retryAfter;

  OtpApiException(this.code, {this.retryAfter});

  String get message {
    switch (code) {
      case 'INVALID_PHONE':
        return 'Enter a valid 10-digit mobile number.';
      case 'INVALID_OTP':
        return 'Wrong or expired OTP. Please try again.';
      case 'LOCKED':
        return 'Too many wrong attempts. Try again in ${_wait()}.';
      case 'RATE_LIMITED':
        return 'Too many requests. Try again in ${_wait()}.';
      case 'OTP_SEND_FAILED':
        return 'Could not send the OTP. Please try again.';
      case 'ALREADY_EXISTS':
        return 'That username or email is already taken.';
      case 'PHONE_IN_USE':
        return 'This number is linked to another account.';
      case 'INVALID_USERNAME':
        return 'Username must be 3–30 letters, numbers, _ or .';
      case 'INVALID_EMAIL':
        return 'Enter a valid email address.';
      case 'NETWORK':
        return 'No internet connection. Please check and retry.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  String _wait() {
    final s = retryAfter ?? 60;
    return s >= 60 ? '${(s / 60).ceil()} min' : '$s sec';
  }
}

// ============================================================
// RESULT TYPES
// ============================================================

class OtpVerifyResult {
  final bool needsSignup;
  final String? signupToken;
  OtpVerifyResult({required this.needsSignup, this.signupToken});
}

// ============================================================
// REPOSITORY
// Uses the app's existing DioClient (registered in GetIt) and
// LocalStorage (SharedPreferences) — no second token system.
// ============================================================

class OtpAuthRepository {
  final DioClient _dioClient;

  OtpAuthRepository({DioClient? dioClient})
      : _dioClient = dioClient ?? sl<DioClient>();

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body, {
    String? bearer,
  }) async {
    try {
      final fullPath = '${ApiEndpoints.baseUrl}$path';
      final Options? options = bearer != null
          ? Options(headers: {'Authorization': 'Bearer $bearer'})
          : null;
      final response = await _dioClient.dio.post(
        fullPath,
        data: body,
        options: options,
      );
      return (response.data as Map<String, dynamic>?) ?? {};
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map) {
        final code = (data['error'] ?? 'UNKNOWN').toString();
        final retryAfter = (data['retry_after'] as num?)?.toInt() ??
            int.tryParse(e.response?.headers.value('retry-after') ?? '');
        throw OtpApiException(code, retryAfter: retryAfter);
      }
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw OtpApiException('NETWORK');
      }
      throw OtpApiException('UNKNOWN');
    } catch (e) {
      if (e is OtpApiException) rethrow;
      throw OtpApiException('NETWORK');
    }
  }

  /// Saves the session returned by verify/signup into LocalStorage,
  /// using the exact same keys the email login flow writes.
  Future<void> _saveSession(Map<String, dynamic> data) async {
    final ls = LocalStorage.instance;

    // Backend returns `access_token`; email login also uses a plain token.
    final token = (data['access_token'] ?? data['token'] ?? '').toString();
    if (token.isNotEmpty) await ls.saveToken(token);

    final userRaw = data['user'];
    if (userRaw is Map) {
      final user = Map<String, dynamic>.from(userRaw);

      final userId =
          (user['_id'] ?? user['id'] ?? user['userId'])?.toString() ?? '';
      if (userId.isNotEmpty) await ls.saveUserId(userId);

      final email = (user['email'])?.toString() ?? '';
      if (email.isNotEmpty) await ls.saveUserEmail(email);

      final name =
          (user['fullName'] ?? user['name'] ?? user['username'])?.toString() ??
              '';
      if (name.isNotEmpty) await ls.saveUserName(name);

      final photo =
          (user['profilePhoto'] ?? user['profile_photo'] ?? user['avatar'])
                  ?.toString() ??
              '';
      if (photo.isNotEmpty) await ls.saveUserProfilePhoto(photo);

      final role = (user['role'])?.toString() ?? '';
      if (role.isNotEmpty) await ls.saveUserRole(role);

      final trkCode =
          (user['trkCode'] ?? user['trk_code'])?.toString() ?? '';
      if (trkCode.isNotEmpty) await ls.saveUserTrkCode(trkCode);

      final mobile = (user['mobile'])?.toString() ?? '';
      if (mobile.isNotEmpty) await ls.saveUserMobile(mobile);

      await ls.saveUserData(user);
    }
  }

  // ── Public API ─────────────────────────────────────────────

  Future<int> sendOtp(String phone10) async {
    final d = await _post('/auth/otp/send', {'phone': phone10});
    return (d['resend_after_seconds'] as num?)?.toInt() ?? 30;
  }

  Future<int> resendOtp(String phone10) async {
    final d = await _post('/auth/otp/resend', {'phone': phone10});
    return (d['resend_after_seconds'] as num?)?.toInt() ?? 30;
  }

  Future<OtpVerifyResult> verifyOtp(String phone10, String otp) async {
    final d =
        await _post('/auth/otp/verify', {'phone': phone10, 'otp': otp});
    if (d['needs_signup'] == true) {
      return OtpVerifyResult(
          needsSignup: true,
          signupToken: d['signup_token']?.toString());
    }
    await _saveSession(d);
    return OtpVerifyResult(needsSignup: false);
  }

  Future<void> otpSignup({
    required String signupToken,
    required String username,
    String? email,
    String? fullName,
  }) async {
    final d = await _post('/auth/otp/signup', {
      'signup_token': signupToken,
      'username': username,
      if (email != null && email.isNotEmpty) 'email': email,
      if (fullName != null && fullName.isNotEmpty) 'full_name': fullName,
    });
    await _saveSession(d);
  }

  // ── Phone-linking for logged-in users ──────────────────────

  Future<int> sendLinkOtp(String phone10) async {
    final token = LocalStorage.instance.getToken() ?? '';
    final d = await _post(
        '/auth/otp/link/send', {'phone': phone10},
        bearer: token);
    return (d['resend_after_seconds'] as num?)?.toInt() ?? 30;
  }

  Future<void> verifyLinkOtp(String phone10, String otp) async {
    final token = LocalStorage.instance.getToken() ?? '';
    await _post(
        '/auth/otp/link/verify', {'phone': phone10, 'otp': otp},
        bearer: token);
    await LocalStorage.instance.saveUserMobile(phone10);
  }
}
