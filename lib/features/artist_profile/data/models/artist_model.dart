import 'package:flutter/foundation.dart';
import 'portfolio_model.dart';

@immutable
class ArtistModel {
  final String id;
  final String name;
  final String country;
  final String state;
  final String city;
  final String profileImage;
  final String coverImage;
  final List<String> roles;

  final int projects;
  final String followers;
  final double rating;
  final int awards;
  final bool following;

  final String experience;
  final String languages;
  final List<PortfolioModel> portfolio;

  const ArtistModel({
    this.id = '',
    required this.name,
    this.country = '',
    required this.state,
    required this.city,
    required this.profileImage,
    required this.coverImage,
    required this.roles,
    required this.projects,
    required this.followers,
    required this.rating,
    required this.awards,
    this.following = false,
    required this.experience,
    required this.languages,
    this.portfolio = const [],
  });

  /// GET /users/{id} nests city, experience, languages, etc. under `details`.
  static Map<String, dynamic> _flatten(Map<String, dynamic> json) {
    final merged = <String, dynamic>{};

    final details = json['details'];
    if (details is Map) {
      merged.addAll(Map<String, dynamic>.from(details));
    }

    json.forEach((key, value) {
      if (key == 'details') return;
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      merged[key] = value;
    });

    return merged;
  }

  factory ArtistModel.fromJson(Map<String, dynamic> json) {
    final data = _flatten(json);

    return ArtistModel(
      id: _stringValue(
        data['_id'] ?? data['id'] ?? json['_id'] ?? json['id'],
      ),
      name: _stringValue(
        data['fullName'] ?? data['name'] ?? data['stageName'],
      ),
      country: _stringValue(
        data['country'],
      ),
      state: _stringValue(
        data['state'] ?? (data['location'] != null && data['location'].toString().contains(',')
            ? data['location'].toString().split(',').sublist(1).join(',').trim()
            : null),
      ),
      city: _stringValue(
        data['city'] ?? (data['location'] != null && data['location'].toString().contains(',')
            ? data['location'].toString().split(',')[0].trim()
            : data['location']),
      ),
      profileImage: _imageValue(
        data['pic'] ??
            data['profilePhoto'] ??
            data['profile_image'] ??
            data['profileImage'] ??
            data['avatar'],
      ),
      coverImage: _imageValue(
        data['cover_image'] ??
            data['coverImage'] ??
            data['coverPhoto'],
      ),
      roles: _listValue(
        data['role'] ?? data['roles'] ?? data['category'],
      ),
      projects: _intValue(
        data['projects'] ??
            data['projectsCount'] ??
            data['projects_count'] ??
            data['videosCount'] ??
            data['videos_count'] ??
            data['photosCount'] ??
            data['postsCount'] ??
            (data['portfolio'] is List ? (data['portfolio'] as List).length : null) ??
            (data['previousWork'] is List ? (data['previousWork'] as List).length : null),
      ),
      followers: _followersValue(data, rawJson: json),
      rating: _doubleValue(
        data['rating'],
      ),
      awards: _awardsValue(
        data['awards'] ?? data['awardsCount'] ?? data['awards_count'] ?? data['achievements'],
      ),
      following: data['following'] == true || json['following'] == true || data['isFollowing'] == true,
      experience: _stringValue(
        data['experience'],
      ),
      languages: _stringValue(
        data['languages'] ?? data['actingLanguages'] ?? data['preferredLanguage'],
      ),
      portfolio: _portfolioFromProfile(data),
    );
  }

  ArtistModel copyWith({
    String? id,
    String? name,
    String? country,
    String? state,
    String? city,
    String? profileImage,
    String? coverImage,
    List<String>? roles,
    int? projects,
    String? followers,
    double? rating,
    int? awards,
    bool? following,
    String? experience,
    String? languages,
    List<PortfolioModel>? portfolio,
  }) {
    return ArtistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      state: state ?? this.state,
      city: city ?? this.city,
      profileImage: profileImage ?? this.profileImage,
      coverImage: coverImage ?? this.coverImage,
      roles: roles ?? this.roles,
      projects: projects ?? this.projects,
      followers: followers ?? this.followers,
      rating: rating ?? this.rating,
      awards: awards ?? this.awards,
      following: following ?? this.following,
      experience: experience ?? this.experience,
      languages: languages ?? this.languages,
      portfolio: portfolio ?? this.portfolio,
    );
  }

  static String followersValueFromMap(Map<String, dynamic> data, {Map<String, dynamic>? rawJson}) {
    return _followersValue(data, rawJson: rawJson);
  }

  static String _followersValue(Map<String, dynamic> data, {Map<String, dynamic>? rawJson}) {
    dynamic val = data['followers'] ??
        data['followersCount'] ??
        data['followers_count'] ??
        data['followerCount'] ??
        data['totalFollowers'] ??
        data['numFollowers'] ??
        data['followersTotal'] ??
        data['stats']?['followers'] ??
        data['counts']?['followers'] ??
        rawJson?['followers'] ??
        rawJson?['followersCount'] ??
        rawJson?['followers_count'] ??
        rawJson?['followerCount'] ??
        rawJson?['details']?['followers'] ??
        rawJson?['details']?['followersCount'];

    if (val == null) return '0';

    if (val is int) return val.toString();
    if (val is num) return val.toInt().toString();

    if (val is List) {
      return val.length.toString();
    }

    if (val is String) {
      final trimmed = val.trim();
      if (trimmed.isEmpty) return '0';
      final parsedInt = int.tryParse(trimmed);
      if (parsedInt != null) return parsedInt.toString();
      if (trimmed.contains(',')) {
        return trimmed.split(',').where((s) => s.trim().isNotEmpty).length.toString();
      }
      return trimmed;
    }

    return val.toString();
  }

  static List<PortfolioModel> _portfolioFromProfile(Map<String, dynamic> data) {
    final items = <PortfolioModel>[];
    final seen = <String>{};

    void addMedia({
      required String url,
      required bool isVideo,
      String? title,
      String? id,
    }) {
      final trimmed = url.trim();
      if (trimmed.isEmpty || !trimmed.startsWith('http') || seen.contains(trimmed)) {
        return;
      }
      seen.add(trimmed);
      items.add(PortfolioModel(
        id: id ?? '',
        image: trimmed,
        videoUrl: isVideo ? trimmed : null,
        title: title,
        isVideo: isVideo,
      ));
    }

    addMedia(url: _stringValue(data['introVideo']), isVideo: true, title: 'Intro');
    addMedia(url: _stringValue(data['headshot']), isVideo: false, title: 'Headshot');
    addMedia(url: _stringValue(data['fullBody']), isVideo: false, title: 'Full body');

    final previousWork = data['previousWork'];
    if (previousWork is List) {
      for (final item in previousWork) {
        if (item is Map) {
          items.addAll(
            _portfolioValue(item).where((p) => seen.add(p.image)),
          );
        } else if (item is String && item.startsWith('http')) {
          addMedia(url: item, isVideo: item.toLowerCase().contains('.mp4'));
        }
      }
    }

    for (final source in [data['portfolio'], data['photos'], data['videos'], data['posts']]) {
      for (final item in _portfolioValue(source)) {
        if (item.image.isNotEmpty && seen.add(item.image)) {
          items.add(item);
        }
      }
    }

    return items;
  }

  static List<PortfolioModel> _portfolioValue(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((e) => PortfolioModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  static int _awardsValue(dynamic value) {
    if (value == null) return 0;
    if (value is List) {
      return value.where((item) => item.toString().trim().isNotEmpty).length;
    }
    if (value is int) return value;
    if (value is num) return value.toInt();
    final text = value.toString().trim();
    if (text.isEmpty) return 0;
    return int.tryParse(text) ??
        text.split(',').where((part) => part.trim().isNotEmpty).length;
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
      'country': country,
      'state': state,
      'city': city,
      'profile_image': profileImage,
      'cover_image': coverImage,
      'roles': roles,
      'projects': projects,
      'followers': followers,
      'rating': rating,
      'awards': awards,
      'following': following,
      'experience': experience,
      'languages': languages,
      'portfolio': portfolio.map((e) => e.toJson()).toList(),
    };
  }
}