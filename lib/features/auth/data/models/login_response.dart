class UserModel {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String? mobile;
  final int? age;
  final String? gender;
  final String? role;
  final String? profilePhoto;
  final String? trkCode;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.mobile,
    this.age,
    this.gender,
    this.role,
    this.profilePhoto,
    this.trkCode,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['_id'] ?? json['userId'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      fullName: (json['fullName'] ?? json['name'] ?? json['username'] ?? '').toString(),
      mobile: json['mobile']?.toString(),
      age: json['age'] is num
          ? (json['age'] as num).toInt()
          : int.tryParse(json['age']?.toString() ?? ''),
      gender: json['gender']?.toString(),
      role: json['role']?.toString(),
      profilePhoto: json['profilePhoto']?.toString() ??
          json['profile_photo']?.toString() ??
          json['avatar']?.toString(),
      trkCode: json['trkCode']?.toString() ?? json['trk_code']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      if (mobile != null) 'mobile': mobile,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (role != null) 'role': role,
      if (profilePhoto != null) 'profilePhoto': profilePhoto,
      if (trkCode != null) 'trkCode': trkCode,
    };
  }
}

class LoginResponse {
  final String token;
  final UserModel? userModel;
  final Map<String, dynamic>? user;
  final String? message;

  LoginResponse({
    required this.token,
    this.userModel,
    this.user,
    this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final token =
        json['token'] ??
        json['accessToken'] ??
        json['access_token'] ??
        '';

    final userMap =
        json['user'] is Map
            ? Map<String, dynamic>.from(json['user'])
            : null;

    final userModel =
        userMap != null
            ? UserModel.fromJson(userMap)
            : null;

    return LoginResponse(
      token: token.toString(),
      userModel: userModel,
      user: userMap,
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': userModel?.toJson() ?? user,
      'message': message,
    };
  }
}