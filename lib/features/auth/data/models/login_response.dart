class LoginResponse {
  final String token;
  final Map<String, dynamic>? user;
  final String? message;

  LoginResponse({
    required this.token,
    this.user,
    this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final token =
        json['token'] ??
            json['accessToken'] ??
            json['access_token'] ??
            '';

    final user =
    json['user'] is Map
        ? Map<String, dynamic>.from(json['user'])
        : null;

    return LoginResponse(
      token: token.toString(),
      user: user,
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user,
      'message': message,
    };
  }
}