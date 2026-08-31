import 'package:flutter/foundation.dart';

@immutable
class TalentModel {
  final String id;
  final String name;
  final String category;
  final String bio;
  final String pic;
  final String handle;
  final int followers;
  final int videosCount;
  final bool following;
  final int matchPercent;
  final String city;
  final String state;
  final String country;

  const TalentModel({
    this.id = '',
    this.name = '',
    this.category = '',
    this.bio = '',
    this.pic = '',
    this.handle = '',
    this.followers = 0,
    this.videosCount = 0,
    this.following = false,
    this.matchPercent = 0,
    this.city = '',
    this.state = '',
    this.country = '',
  });

  bool get hasCity => city.trim().isNotEmpty;

  bool matchesLocation(String selected) {
    final loc = _normalizePlace(selected);
    if (loc.isEmpty || loc == 'anywhere') return true;

    final aliases = <String, Set<String>>{
      'bangalore': {'bengaluru'},
      'bengaluru': {'bangalore'},
      'hyderabad': {'hyd', 'hydrabad', 'secunderabad', 'cyberabad'},
      'delhi': {'newdelhi'},
      'newdelhi': {'delhi'},
      'mumbai': {'bombay'},
    };

    bool fieldMatches(String value) {
      final field = _normalizePlace(value);
      if (field.isEmpty) return false;
      if (field == loc || field.contains(loc) || (field.length >= 4 && loc.contains(field))) {
        return true;
      }
      final locAliases = aliases[loc] ?? {};
      final fieldAliases = aliases[field] ?? {};
      return locAliases.contains(field) || fieldAliases.contains(loc);
    }

    // Match the artist's city (and state only if they stored the city name there).
    // Do not match country — "India" must not hide or include city filters.
    return fieldMatches(city) || fieldMatches(state);
  }

  static String _normalizePlace(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
  }

  TalentModel copyWith({
    String? city,
    String? state,
    String? country,
  }) {
    return TalentModel(
      id: id,
      name: name,
      category: category,
      bio: bio,
      pic: pic,
      handle: handle,
      followers: followers,
      videosCount: videosCount,
      following: following,
      matchPercent: matchPercent,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
    );
  }

  factory TalentModel.fromJson(Map<String, dynamic> json) {
    final data = _flatten(json);

    String parseString(dynamic v) {
      if (v == null) return '';
      if (v is String) return v.trim();
      if (v is List && v.isNotEmpty) return parseString(v.first);
      if (v is Map) {
        return parseString(
          v['city'] ?? v['name'] ?? v['title'] ?? v['value'],
        );
      }
      return v.toString().trim();
    }

    int parseInt(dynamic v) {
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    final location = data['location'];
    String locationCity = '';
    String locationState = '';
    if (location is Map) {
      locationCity = parseString(location['city'] ?? location['name']);
      locationState = parseString(location['state']);
    } else if (location is String && location.trim().isNotEmpty) {
      final parts = location.split(',').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
      if (parts.isNotEmpty) locationCity = parts.first;
      if (parts.length > 1) locationState = parts.sublist(1).join(', ');
    }

    return TalentModel(
      id: parseString(data['id'] ?? data['_id']),
      name: parseString(data['name'] ?? data['fullName']),
      category: parseString(data['category'] ?? data['role']),
      bio: parseString(data['bio']),
      pic: parseString(data['pic'] ?? data['profilePhoto'] ?? data['image']),
      handle: parseString(data['handle']),
      followers: parseInt(data['followers']),
      videosCount: parseInt(data['videosCount']),
      following: data['following'] == true,
      matchPercent: parseInt(
        data['match'] ?? data['matchPercentage'] ?? data['matchPercent'],
      ),
      city: parseString(
        data['city'] ?? data['currentCity'] ?? data['hometown'] ?? locationCity,
      ),
      state: parseString(data['state'] ?? locationState),
      country: parseString(data['country']),
    );
  }

  static Map<String, dynamic> _flatten(Map<String, dynamic> json) {
    final merged = <String, dynamic>{};

    void mergeDetails(dynamic details) {
      if (details is Map) {
        merged.addAll(Map<String, dynamic>.from(details));
      }
    }

    mergeDetails(json['details']);
    final nested = json['user'] ?? json['artist'] ?? json['profile'];
    if (nested is Map) {
      final nestedMap = Map<String, dynamic>.from(nested);
      mergeDetails(nestedMap['details']);
      nestedMap.forEach((key, value) {
        if (key == 'details') return;
        if (value == null) return;
        if (value is String && value.trim().isEmpty) return;
        merged[key] = value;
      });
    }

    json.forEach((key, value) {
      if (key == 'details' || key == 'user' || key == 'artist' || key == 'profile') {
        return;
      }
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      merged[key] = value;
    });

    return merged;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'bio': bio,
        'pic': pic,
        'handle': handle,
        'followers': followers,
        'videosCount': videosCount,
        'following': following,
      };
}
