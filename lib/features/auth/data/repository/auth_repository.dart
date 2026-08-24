import '../../../../core/storage/local_storage.dart';

import '../datasource/auth_remote_datasource.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';

abstract class AuthRepository {
  Future<LoginResponse> login(
      String email,
      String password,
      );

  Future<LoginResponse> register(
      RegisterRequest request,
      );

  Future<void> logout();

  bool isUserLoggedIn();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final LocalStorage _localStorage;

  AuthRepositoryImpl(
      this._remoteDataSource,
      this._localStorage,
      );

  // ============================
  // LOGIN
  // ============================

  @override
  Future<LoginResponse> login(
      String email,
      String password,
      ) async {
    final response = await _remoteDataSource.login(
      email,
      password,
    );

    if (response.token.isNotEmpty) {
      await _localStorage.saveToken(
        response.token,
      );

      await _localStorage.saveUserEmail(
        email,
      );

      if (response.user != null) {
        final userId = response.user!['_id'] ??
            response.user!['id'] ??
            response.user!['userId'];
        if (userId != null && userId.toString().isNotEmpty) {
          await _localStorage.saveUserId(userId.toString());
        }

        final name = response.user!['fullName'] ??
            response.user!['name'] ??
            response.user!['username'];
        if (name != null && name.toString().isNotEmpty) {
          await _localStorage.saveUserName(name.toString());
        }

        final photo = response.user!['profilePhoto'] ??
            response.user!['profile_photo'] ??
            response.user!['avatar'];
        if (photo != null && photo.toString().isNotEmpty) {
          await _localStorage.saveUserProfilePhoto(photo.toString());
        }
      }
    }

    return response;
  }

  // ============================
  // REGISTER
  // ============================

  @override
  Future<LoginResponse> register(
      RegisterRequest request,
      ) async {
    final response =
    await _remoteDataSource.register(request);

    // If backend automatically logs user in
    // after registration.
    if (response.token.isNotEmpty) {
      await _localStorage.saveToken(
        response.token,
      );

      await _localStorage.saveUserEmail(
        request.email,
      );

      if (request.fullName.isNotEmpty) {
        await _localStorage.saveUserName(request.fullName);
      }

      if (response.user != null) {
        final userId = response.user!['_id'] ??
            response.user!['id'] ??
            response.user!['userId'];
        if (userId != null && userId.toString().isNotEmpty) {
          await _localStorage.saveUserId(userId.toString());
        }

        final name = response.user!['fullName'] ??
            response.user!['name'] ??
            response.user!['username'];
        if (name != null && name.toString().isNotEmpty) {
          await _localStorage.saveUserName(name.toString());
        }

        final photo = response.user!['profilePhoto'] ??
            response.user!['profile_photo'] ??
            response.user!['avatar'];
        if (photo != null && photo.toString().isNotEmpty) {
          await _localStorage.saveUserProfilePhoto(photo.toString());
        }
      }
    }

    return response;
  }

  // ============================
  // LOGOUT
  // ============================

  @override
  Future<void> logout() async {
    await _localStorage.clearAll();
  }

  // ============================
  // CHECK LOGIN
  // ============================

  @override
  bool isUserLoggedIn() {
    return _localStorage.hasToken();
  }
}