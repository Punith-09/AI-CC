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
  final bool? explicitFollowing;
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
    this.explicitFollowing,
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

  bool matchesCategory(String selected) {
    final s = selected.trim().toLowerCase();
    if (s.isEmpty || s == 'all') return true;

    final cat = category.trim().toLowerCase();
    final b = bio.trim().toLowerCase();
    final h = handle.trim().toLowerCase();

    // Direct match / contains
    if (cat.isNotEmpty && (cat == s || cat.contains(s) || s.contains(cat))) {
      return true;
    }

    // Comprehensive craft synonyms mapping
    const synonyms = <String, List<String>>{
      'acting': ['actor', 'actress', 'acting', 'artist', 'hero', 'heroine', 'cast'],
      'dancing': ['dancer', 'dancing', 'dance', 'choreography', 'choreographer'],
      'singing': ['singer', 'singing', 'vocalist', 'playback', 'song'],
      'music': ['musician', 'music', 'composer', 'music director', 'bgm', 'score'],
      'direction': ['director', 'direction', 'asst director', 'assistant director', 'ad', 'filmmaker'],
      'cinematography': ['cinematographer', 'cinematography', 'dop', 'camera', 'cameraman'],
      'editing': ['editor', 'editing', 'film editor', 'video editor'],
      'stunts': ['stunt', 'stunts', 'action', 'fight', 'action director'],
      'choreography': ['choreographer', 'choreography', 'dance master', 'dancer', 'dancing'],
      'art direction': ['art director', 'art direction', 'production design', 'set designer', 'art'],
      'costumes': ['costume', 'costumes', 'costume designer', 'stylist', 'wardrobe'],
      'makeup': ['makeup', 'makeup artist', 'mua'],
      'hair dressing': ['hair', 'hair stylist', 'hair dresser', 'hair dressing'],
      'audiography': ['audiography', 'sound', 'sound design', 'sound recording', 'audio', 'sound editor'],
      'production': ['production', 'producer', 'executive producer', 'line producer', 'production manager'],
      'production executives': ['production executive', 'production executives', 'ep', 'line producer', 'producer'],
      'outdoor units': ['outdoor units', 'outdoor unit', 'location team', 'equipment'],
      'still photography': ['still photography', 'photographer', 'photo'],
      'publicity': ['publicity', 'pr', 'public relations', 'promotion'],
      'publicity design': ['publicity design', 'poster design', 'graphic designer', 'designer'],
      'lyrics': ['lyricist', 'lyrics', 'song writer'],
      'dialogues': ['dialogue', 'dialogues', 'dialogue writer', 'writer'],
      'screenplay': ['screenplay', 'screenplay writer', 'writer', 'script'],
      'story': ['story', 'story writer', 'writer'],
    };

    final syns = synonyms[s];
    if (syns != null) {
      for (final syn in syns) {
        if (cat.contains(syn) || syn.contains(cat) || b.contains(syn) || h.contains(syn)) {
          return true;
        }
      }
    } else {
      if (b.contains(s) || h.contains(s)) return true;
    }

    return false;
  }

  static String _normalizePlace(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
  }

  TalentModel copyWith({
    String? city,
    String? state,
    String? country,
    bool? following,
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
      following: following ?? this.following,
      explicitFollowing: explicitFollowing,
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

    final bool? explicitFollowing = (data['following'] is bool)
        ? data['following'] as bool
        : (data['isFollowing'] is bool
            ? data['isFollowing'] as bool
            : (json['following'] is bool
                ? json['following'] as bool
                : (json['isFollowing'] is bool ? json['isFollowing'] as bool : null)));

    return TalentModel(
      id: parseString(data['id'] ?? data['_id']),
      name: parseString(data['name'] ?? data['fullName']),
      category: parseString(data['category'] ?? data['role']),
      bio: parseString(data['bio']),
      pic: parseString(data['pic'] ?? data['profilePhoto'] ?? data['image']),
      handle: parseString(data['handle']),
      followers: parseInt(data['followers']),
      videosCount: parseInt(data['videosCount']),
      following: explicitFollowing == true,
      explicitFollowing: explicitFollowing,
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
