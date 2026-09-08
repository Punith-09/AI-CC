import '../../../../core/storage/local_storage.dart';

import '../datasource/auth_remote_datasource.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';
import '../datasource/google_auth_datasource.dart';

abstract class AuthRepository {
  Future<LoginResponse> login(
      String email,
      String password,
      );

  Future<LoginResponse> register(
      RegisterRequest request,
      );

  Future<void> loginWithGoogle();

  Future<void> logout();

  bool isUserLoggedIn();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final GoogleAuthDataSource _googleAuthDataSource;
  final LocalStorage _localStorage;

  AuthRepositoryImpl(
      this._remoteDataSource,
      this._googleAuthDataSource,
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
  // GOOGLE LOGIN
  // ============================

  @override
  Future<void> loginWithGoogle() async {
    // 1. Get Firebase User Credential
    final userCredential = await _googleAuthDataSource.signInWithGoogle();
    
    // 2. Get the ID token from Firebase
    final idToken = await userCredential.user?.getIdToken();
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Failed to get Google ID token from Firebase');
    }

    // 3. Send the ID token to the backend
    final response = await _remoteDataSource.loginWithGoogle(idToken);

    // 4. Save tokens and user info locally
    if (response.token.isNotEmpty) {
      await _localStorage.saveToken(
        response.token,
      );
      
      if (userCredential.user?.email != null) {
         await _localStorage.saveUserEmail(
           userCredential.user!.email!,
         );
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
  }

  // ============================
  // LOGOUT
  // ============================

  @override
  Future<void> logout() async {
    await _googleAuthDataSource.signOut();
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