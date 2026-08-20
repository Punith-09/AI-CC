import 'package:flutter/foundation.dart';

@immutable
class TalentModel {
  final String id;
  final String image;
  final String name;
  final String role;
  final int match;

  const TalentModel({
    this.id = '',
    required this.image,
    required this.name,
    required this.role,
    required this.match,
  });

  factory TalentModel.fromJson(Map<String, dynamic> json) {
    String parsedRole = '';
    if (json['role'] is String) {
      parsedRole = json['role'];
    } else if (json['roles'] is List && (json['roles'] as List).isNotEmpty) {
      parsedRole = (json['roles'] as List).first.toString();
    }

    return TalentModel(
      id: (json['_id'] as String?) ?? (json['id'] as String?) ?? '',
      image: (json['profilePhoto'] as String?) ?? (json['image'] as String?) ?? '',
      name: (json['fullName'] as String?) ?? (json['name'] as String?) ?? '',
      role: parsedRole,
      match: json['match'] as int? ?? 90, // default match to some value if null
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'image': image,
        'name': name,
        'role': role,
        'match': match,
      };
}
