import 'package:flutter/foundation.dart';
import 'portfolio_model.dart';

@immutable
class ArtistModel {
  final String id;
  final String name;
  final String state;
  final String city;
  final String profileImage;
  final String coverImage;
  final List<String> roles;

  final int projects;
  final String followers;
  final double rating;
  final int awards;

  final String experience;
  final String languages;
  final List<PortfolioModel> portfolio;

  const ArtistModel({
    this.id = '',
    required this.name,
    required this.state,
    required this.city,
    required this.profileImage,
    required this.coverImage,
    required this.roles,
    required this.projects,
    required this.followers,
    required this.rating,
    required this.awards,
    required this.experience,
    required this.languages,
    this.portfolio = const [],
  });

  factory ArtistModel.fromJson(Map<String, dynamic> json) {
    return ArtistModel(
      id: _stringValue(
        json['_id'] ?? json['id'],
      ),
      name: _stringValue(
        json['fullName'] ?? json['name'],
      ),
      state: _stringValue(
        json['state'] ?? (json['location'] != null && json['location'].toString().contains(',') 
            ? json['location'].toString().split(',').sublist(1).join(',').trim() 
            : null),
      ),
      city: _stringValue(
        json['city'] ?? (json['location'] != null && json['location'].toString().contains(',') 
            ? json['location'].toString().split(',')[0].trim() 
            : json['location']),
      ),
      profileImage: _imageValue(
        json['profilePhoto'] ??
            json['profile_image'] ??
            json['profileImage'] ??
            json['pic'],
      ),
      coverImage: _imageValue(
        json['cover_image'] ??
            json['coverImage'] ??
            json['coverPhoto'],
      ),
      roles: _listValue(
        json['roles'] ?? json['role'] ?? json['category'],
      ),
      projects: _intValue(
        json['projects'] ?? json['videosCount'],
      ),
      followers: _stringValue(
        json['followers'],
      ),
      rating: _doubleValue(
        json['rating'],
      ),
      awards: _intValue(
        json['awards'],
      ),
      experience: _stringValue(
        json['experience'],
      ),
      languages: _stringValue(
        json['languages'] ?? json['actingLanguages'],
      ),
      portfolio: _portfolioValue(
        json['portfolio'] ?? json['photos'] ?? json['videos'] ?? json['posts'],
      ),
    );
  }

  static List<PortfolioModel> _portfolioValue(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map<String, dynamic>>()
          .map((e) => PortfolioModel.fromJson(e))
          .toList();
    }
    return [];
  }

  static String _stringValue(dynamic value) {
    if (value == null) {
      return '';
    }

    if (value is String) {
      return value;
    }

    if (value is List) {
      return value
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .join(', ');
    }

    return value.toString();
  }

  static String _imageValue(dynamic value) {
    if (value == null) {
      return '';
    }

    if (value is String) {
      return value;
    }

    if (value is List && value.isNotEmpty) {
      return value.first.toString();
    }

    return value.toString();
  }

  static List<String> _listValue(dynamic value) {
    if (value == null) {
      return [];
    }

    if (value is String) {
      if (value.trim().isEmpty) {
        return [];
      }

      return value
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    if (value is List) {
      return value
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return [];
  }

  static int _intValue(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? 0;
  }

  static double _doubleValue(dynamic value) {
    if (value == null) {
      return 0.0;
    }

    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'state': state,
      'city': city,
      'profile_image': profileImage,
      'cover_image': coverImage,
      'roles': roles,
      'projects': projects,
      'followers': followers,
      'rating': rating,
      'awards': awards,
      'experience': experience,
      'languages': languages,
      'portfolio': portfolio.map((e) => e.toJson()).toList(),
    };
  }
}