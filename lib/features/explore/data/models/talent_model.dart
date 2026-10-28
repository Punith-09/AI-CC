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
  final String gender;
  final int age;
  final List<String> languages;
  final double heightFt;
  final List<String> skills;
  final String role;
  final String projectType;

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
    this.gender = '',
    this.age = 0,
    this.languages = const [],
    this.heightFt = 0.0,
    this.skills = const [],
    this.role = '',
    this.projectType = '',
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

  bool matchesGender(String selected) {
    final s = selected.trim().toLowerCase();
    if (s.isEmpty || s == 'all') return true;
    final g = gender.trim().toLowerCase();
    if (g.isNotEmpty) {
      if (g == s) return true;
      if (s == 'male' && (g == 'male' || g == 'm' || g == 'man')) return true;
      if (s == 'female' && (g == 'female' || g == 'f' || g == 'woman')) return true;
      if (s == 'other' && (g == 'other' || g == 'others' || g == 'prefer not to say' || g == 'non-binary')) return true;
      return false;
    }
    final b = bio.trim().toLowerCase();
    if (s == 'female' && (b.contains('actress') || b.contains('female') || b.contains('woman') || b.contains('she/her'))) return true;
    if (s == 'male' && (b.contains('actor') || b.contains('male') || b.contains('man') || b.contains('he/him'))) return true;
    return false;
  }

  bool matchesAge(String ageFromStr, String ageToStr) {
    final from = int.tryParse(ageFromStr.trim());
    final to = int.tryParse(ageToStr.trim());
    if (from == null && to == null) return true;
    if (age <= 0) {
      final b = bio.toLowerCase();
      final match = RegExp(r'(\d{2})\s*(?:years?|yrs?|yo|\s*old)').firstMatch(b);
      if (match != null) {
        final a = int.tryParse(match.group(1) ?? '') ?? 0;
        if (a > 0) {
          if (from != null && a < from) return false;
          if (to != null && to > 0 && a > to) return false;
          return true;
        }
      }
      return false;
    }
    if (from != null && age < from) return false;
    if (to != null && to > 0 && age > to) return false;
    return true;
  }

  bool matchesLanguage(String selected) {
    final s = selected.trim().toLowerCase();
    if (s.isEmpty) return true;
    for (final l in languages) {
      final lang = l.trim().toLowerCase();
      if (lang == s || lang.contains(s) || s.contains(lang)) return true;
    }
    final b = bio.toLowerCase();
    return b.contains(s);
  }

  bool matchesHeight(String heightFromStr, String heightToStr) {
    double? toInches(String val) {
      final v = val.trim().toLowerCase();
      if (v.isEmpty) return null;
      final numStr = v.replaceAll(RegExp(r'[^0-9.]'), '');
      if (numStr.isEmpty) return null;
      final parts = numStr.split('.');
      final ft = double.tryParse(parts[0]) ?? 0;
      final inch = (parts.length > 1) ? (double.tryParse(parts[1]) ?? 0) : 0;
      return (ft * 12.0) + inch;
    }

    final fromInches = toInches(heightFromStr);
    final toInchesVal = toInches(heightToStr);
    if (fromInches == null && toInchesVal == null) return true;

    final talentInches = heightFt * 12.0;
    if (talentInches <= 0) {
      return false;
    }
    if (fromInches != null && talentInches < (fromInches - 0.5)) return false;
    if (toInchesVal != null && talentInches > (toInchesVal + 0.5)) return false;
    return true;
  }

  bool matchesSkills(String selected) {
    final s = selected.trim().toLowerCase();
    if (s.isEmpty) return true;
    for (final sk in skills) {
      final skl = sk.trim().toLowerCase();
      if (skl == s || skl.contains(s) || s.contains(skl)) return true;
    }
    if (matchesCategory(selected)) return true;
    final b = bio.toLowerCase();
    final c = category.toLowerCase();
    return b.contains(s) || c.contains(s);
  }

  bool matchesRole(String selected) {
    final s = selected.trim().toLowerCase();
    if (s.isEmpty) return true;
    final r = role.toLowerCase();
    if (r == s || r.contains(s) || s.contains(r)) return true;
    final b = bio.toLowerCase();
    final c = category.toLowerCase();
    return b.contains(s) || c.contains(s);
  }

  bool matchesProjectType(String selected) {
    final s = selected.trim().toLowerCase();
    if (s.isEmpty) return true;
    final p = projectType.toLowerCase();
    if (p == s || p.contains(s) || s.contains(p)) return true;
    final b = bio.toLowerCase();
    final c = category.toLowerCase();
    return b.contains(s) || c.contains(s);
  }

  static String _normalizePlace(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
  }

  TalentModel copyWith({
    String? city,
    String? state,
    String? country,
    bool? following,
    String? gender,
    int? age,
    List<String>? languages,
    double? heightFt,
    List<String>? skills,
    String? role,
    String? projectType,
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
      gender: gender ?? this.gender,
      age: age ?? this.age,
      languages: languages ?? this.languages,
      heightFt: heightFt ?? this.heightFt,
      skills: skills ?? this.skills,
      role: role ?? this.role,
      projectType: projectType ?? this.projectType,
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

    String parseStringOrJoinList(dynamic v) {
      if (v == null) return '';
      if (v is String) return v.trim();
      if (v is List) {
        return v.map((e) => parseString(e)).where((e) => e.isNotEmpty).join(', ');
      }
      if (v is Map) {
        return parseString(v['name'] ?? v['title'] ?? v['value']);
      }
      return v.toString().trim();
    }

    int parseInt(dynamic v) {
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    final location = data['location'] ?? json['location'];
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

    int parsedAge = parseInt(data['age'] ?? json['age']);
    final dobVal = data['dob'] ?? data['dateOfBirth'] ?? json['dob'] ?? json['dateOfBirth'];
    if (parsedAge == 0 && dobVal != null) {
      try {
        final dobStr = dobVal.toString();
        final dob = DateTime.tryParse(dobStr);
        if (dob != null) {
          final now = DateTime.now();
          parsedAge = now.year - dob.year;
          if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
            parsedAge--;
          }
        }
      } catch (_) {}
    }

    List<String> parseList(dynamic raw) {
      if (raw == null) return const [];
      if (raw is List) {
        return raw.map((e) => parseString(e)).where((e) => e.isNotEmpty).toList();
      }
      if (raw is String && raw.isNotEmpty) {
        return raw.split(RegExp(r'[,|/]')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
      return const [];
    }

    double parsedHeightFt = 0.0;
    final rawHeight = data['height'] ?? data['heightInCm'] ?? data['heightInches'] ?? json['height'];
    if (rawHeight != null) {
      final hStr = rawHeight.toString().trim();
      final ftMatch = RegExp(r"(\d+)(?:'|\.|\s*ft\s*)(\d*)").firstMatch(hStr);
      if (ftMatch != null && (hStr.contains("'") || hStr.contains("ft") || hStr.contains("."))) {
        final ft = double.tryParse(ftMatch.group(1) ?? '') ?? 0;
        final inch = double.tryParse(ftMatch.group(2) ?? '') ?? 0;
        parsedHeightFt = ft + (inch / 12.0);
      } else {
        final numVal = double.tryParse(hStr) ?? 0;
        if (numVal >= 100) {
          parsedHeightFt = numVal / 30.48;
        } else if (numVal >= 36) {
          parsedHeightFt = numVal / 12.0;
        } else if (numVal > 0) {
          parsedHeightFt = numVal;
        }
      }
    }

    return TalentModel(
      id: parseString(data['id'] ?? data['_id']),
      name: parseString(data['name'] ?? data['fullName'] ?? data['stageName']),
      category: parseString(data['category'] ?? data['role']),
      bio: parseString(data['bio']),
      pic: parseString(data['pic'] ?? data['profilePhoto'] ?? data['image']),
      handle: parseString(data['handle'] ?? data['username']),
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
      state: parseString(data['state'] ?? data['currentState'] ?? locationState),
      country: parseString(data['country']),
      gender: parseString(data['gender'] ?? data['sex'] ?? json['gender']),
      age: parsedAge,
      languages: parseList(
        data['languages'] ??
        data['actingLanguages'] ??
        data['preferredLanguages'] ??
        data['preferredLanguage'] ??
        data['language'] ??
        json['languages'] ??
        json['preferredLanguages'],
      ),
      heightFt: parsedHeightFt,
      skills: parseList(
        data['skills'] ??
        data['skill'] ??
        data['crafts'] ??
        json['skills'],
      ),
      role: parseStringOrJoinList(
        data['preferredRole'] ??
        data['preferredRoles'] ??
        data['roles'] ??
        data['role'] ??
        json['preferredRole'] ??
        json['roles'] ??
        json['role'],
      ),
      projectType: parseStringOrJoinList(
        data['projectType'] ??
        data['project_type'] ??
        data['availableFor'] ??
        data['projectTypes'] ??
        data['categories'] ??
        json['projectType'] ??
        json['availableFor'],
      ),
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
