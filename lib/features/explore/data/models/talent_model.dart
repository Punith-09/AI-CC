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

    // Safely parse 'match' — backend may return int, double, or String
    int parsedMatch = 90;
    final rawMatch = json['match'];
    if (rawMatch is int) {
      parsedMatch = rawMatch;
    } else if (rawMatch is double) {
      parsedMatch = rawMatch.toInt();
    } else if (rawMatch is String) {
      parsedMatch = int.tryParse(rawMatch) ?? 90;
    }

    // Use toString() instead of hard 'as String?' casts — the backend
    // sometimes returns numeric _id values, which would throw a CastError.
    String _str(dynamic v) => v == null ? '' : v.toString();

    return TalentModel(
      id: _str(json['_id'] ?? json['id']),
      image: _str(json['profilePhoto'] ?? json['image']),
      name: _str(json['fullName'] ?? json['name']),
      role: parsedRole,
      match: parsedMatch,
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
