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
    return TalentModel(
      id: json['id'] as String? ?? '',
      image: json['image'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      match: json['match'] as int? ?? 0,
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
