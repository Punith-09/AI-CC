import '../../../../core/storage/local_storage.dart';
import '../datasource/auth_remote_datasource.dart';
import '../models/login_response.dart';

abstract class AuthRepository {
  Future<LoginResponse> login(String email, String password);
  Future<void> logout();
  bool isUserLoggedIn();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final LocalStorage _localStorage;

  AuthRepositoryImpl(this._remoteDataSource, this._localStorage);

  @override
  Future<LoginResponse> login(String email, String password) async {
    final response = await _remoteDataSource.login(email, password);
    
    // Save token on successful login
    if (response.token.isNotEmpty) {
      await _localStorage.saveToken(response.token);
      await _localStorage.saveUserEmail(email);
    }
    
    return response;
  }

  @override
  Future<void> logout() async {
    await _localStorage.clearAll();
  }

  @override
  bool isUserLoggedIn() {
    return _localStorage.hasToken();
  }
}
