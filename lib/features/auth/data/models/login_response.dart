class LoginResponse {
  final String token;
  final Map<String, dynamic>? user;

  LoginResponse({
    required this.token,
    this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Handles various formats: "token", "accessToken", "access_token"
    final token = json['token'] ?? json['accessToken'] ?? json['access_token'] ?? '';
    final user = json['user'] is Map<String, dynamic> ? json['user'] : null;

    return LoginResponse(
      token: token.toString(),
      user: user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user,
    };
  }
}
