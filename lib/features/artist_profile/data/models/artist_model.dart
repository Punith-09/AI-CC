import 'package:flutter/foundation.dart';

@immutable
class ArtistModel {
  final String id;
  final String name;
  final String location;
  final String profileImage;
  final String coverImage;
  final List<String> roles;

  final int projects;
  final String followers;
  final double rating;
  final int awards;

  final String experience;
  final String languages;

  const ArtistModel({
    this.id = '',
    required this.name,
    required this.location,
    required this.profileImage,
    required this.coverImage,
    required this.roles,
    required this.projects,
    required this.followers,
    required this.rating,
    required this.awards,
    required this.experience,
    required this.languages,
  });

  factory ArtistModel.fromJson(Map<String, dynamic> json) {
    return ArtistModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      location: json['location'] as String? ?? '',
      profileImage: json['profile_image'] as String? ?? '',
      coverImage: json['cover_image'] as String? ?? '',
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      projects: json['projects'] as int? ?? 0,
      followers: json['followers'] as String? ?? '0',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      awards: json['awards'] as int? ?? 0,
      experience: json['experience'] as String? ?? '',
      languages: json['languages'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': location,
        'profile_image': profileImage,
        'cover_image': coverImage,
        'roles': roles,
        'projects': projects,
        'followers': followers,
        'rating': rating,
        'awards': awards,
        'experience': experience,
        'languages': languages,
      };
}
