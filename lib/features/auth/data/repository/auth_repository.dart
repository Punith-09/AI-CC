import '../../../../core/storage/local_storage.dart';

import '../datasource/auth_remote_datasource.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';

import '../datasource/google_auth_datasource.dart';

abstract class AuthRepository {
  Future<LoginResponse> login(
    String identifier,
    String password,
  );

  Future<LoginResponse> register(
    RegisterRequest request,
  );



  Future<void> loginWithGoogle();

  Future<void> logout();

  bool isUserLoggedIn();

  Future<void> forgotPassword(String email);

  Future<void> resetPassword(String token, String newPassword);
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
    String identifier,
    String password,
  ) async {
    final response = await _remoteDataSource.login(
      identifier,
      password,
    );

    if (response.token.isNotEmpty) {
      await _localStorage.saveToken(
        response.token,
      );

      final user = response.userModel;
      final userMap = response.user;

      if (user != null) {
        if (user.id.isNotEmpty) {
          await _localStorage.saveUserId(user.id);
        }
        if (user.email.isNotEmpty) {
          await _localStorage.saveUserEmail(user.email);
        }
        if (user.fullName.isNotEmpty) {
          await _localStorage.saveUserName(user.fullName);
        }
        if (user.profilePhoto != null && user.profilePhoto!.isNotEmpty) {
          await _localStorage.saveUserProfilePhoto(user.profilePhoto!);
        }
        if (user.role != null && user.role!.isNotEmpty) {
          await _localStorage.saveUserRole(user.role!);
        }
        if (user.trkCode != null && user.trkCode!.isNotEmpty) {
          await _localStorage.saveUserTrkCode(user.trkCode!);
        }
        if (user.mobile != null && user.mobile!.isNotEmpty) {
          await _localStorage.saveUserMobile(user.mobile!);
        }
        if (userMap != null) {
          await _localStorage.saveUserData(userMap);
        }
      } else if (userMap != null) {
        final userId = userMap['_id'] ?? userMap['id'] ?? userMap['userId'];
        if (userId != null && userId.toString().isNotEmpty) {
          await _localStorage.saveUserId(userId.toString());
        }

        final email = userMap['email'] ?? identifier;
        if (email != null && email.toString().isNotEmpty) {
          await _localStorage.saveUserEmail(email.toString());
        }

        final name = userMap['fullName'] ?? userMap['name'] ?? userMap['username'];
        if (name != null && name.toString().isNotEmpty) {
          await _localStorage.saveUserName(name.toString());
        }

        final photo = userMap['profilePhoto'] ?? userMap['profile_photo'] ?? userMap['avatar'];
        if (photo != null && photo.toString().isNotEmpty) {
          await _localStorage.saveUserProfilePhoto(photo.toString());
        }

        final role = userMap['role'];
        if (role != null && role.toString().isNotEmpty) {
          await _localStorage.saveUserRole(role.toString());
        }

        final trkCode = userMap['trkCode'] ?? userMap['trk_code'];
        if (trkCode != null && trkCode.toString().isNotEmpty) {
          await _localStorage.saveUserTrkCode(trkCode.toString());
        }

        final mobile = userMap['mobile'];
        if (mobile != null && mobile.toString().isNotEmpty) {
          await _localStorage.saveUserMobile(mobile.toString());
        }

        await _localStorage.saveUserData(userMap);
      } else {
        await _localStorage.saveUserEmail(identifier);
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
    final response = await _remoteDataSource.register(request);

    if (response.token.isNotEmpty) {
      await _localStorage.saveToken(
        response.token,
      );

      await _localStorage.saveUserEmail(
        request.email,
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
  // GOOGLE LOGIN
  // ============================

  @override
  Future<void> loginWithGoogle() async {
    // 1. Get Firebase User Credential
    final userCredential = await _googleAuthDataSource.signInWithGoogle();
    if (userCredential == null) {
      // User cancelled sign-in
      return;
    }
    
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
    try {
      await _localStorage.clearAll();
    } catch (e) {
      // Ignore local storage clear error
    }
    try {
      await _googleAuthDataSource.signOut();
    } catch (e) {
      // Ignore Google/Firebase sign-out error
    }
  }

  // ============================
  // CHECK LOGIN
  // ============================

  @override
  bool isUserLoggedIn() {
    return _localStorage.hasToken();
  }

  // ============================
  // FORGOT PASSWORD
  // ============================

  @override
  Future<void> forgotPassword(String email) async {
    return _remoteDataSource.forgotPassword(email);
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    return _remoteDataSource.resetPassword(token, newPassword);
  }
}