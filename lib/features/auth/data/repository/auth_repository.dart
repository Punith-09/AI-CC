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