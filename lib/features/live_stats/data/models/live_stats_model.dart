class LiveStatsModel {
  final DateTime? updatedAt;
  final UsersStats users;
  final AuditionsStats auditions;
  final ApplicationsStats applications;
  final ContentStats content;

  LiveStatsModel({
    this.updatedAt,
    required this.users,
    required this.auditions,
    required this.applications,
    required this.content,
  });

  factory LiveStatsModel.fromJson(Map<String, dynamic> json) {
    return LiveStatsModel(
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      users: UsersStats.fromJson(json['users'] as Map<String, dynamic>? ?? {}),
      auditions: AuditionsStats.fromJson(
          json['auditions'] as Map<String, dynamic>? ?? {}),
      applications: ApplicationsStats.fromJson(
          json['applications'] as Map<String, dynamic>? ?? {}),
      content:
          ContentStats.fromJson(json['content'] as Map<String, dynamic>? ?? {}),
    );
  }
}

// ─── Users ────────────────────────────────────────────────────────────────────

class UsersStats {
  final int total;
  final int artists;
  final int audience;
  final Map<String, int> byRole;
  final List<NameCount> byCraft;
  final GenderStats byGender;
  final List<NameCount> byState;

  UsersStats({
    required this.total,
    required this.artists,
    required this.audience,
    required this.byRole,
    required this.byCraft,
    required this.byGender,
    required this.byState,
  });

  factory UsersStats.fromJson(Map<String, dynamic> json) {
    return UsersStats(
      total: _toInt(json['total']),
      artists: _toInt(json['artists']),
      audience: _toInt(json['audience']),
      byRole: _toStringIntMap(json['byRole']),
      byCraft: _toNameCountList(json['byCraft']),
      byGender: GenderStats.fromJson(
          json['byGender'] as Map<String, dynamic>? ?? {}),
      byState: _toNameCountList(json['byState']),
    );
  }
}

class GenderStats {
  final int male;
  final int female;
  final int other;
  final int unspecified;

  GenderStats({
    required this.male,
    required this.female,
    required this.other,
    required this.unspecified,
  });

  factory GenderStats.fromJson(Map<String, dynamic> json) {
    return GenderStats(
      male: _toInt(json['male']),
      female: _toInt(json['female']),
      other: _toInt(json['other']),
      unspecified: _toInt(json['unspecified']),
    );
  }
}

// ─── Auditions ────────────────────────────────────────────────────────────────

class AuditionsStats {
  final int total;
  final List<NameCount> byCraft;
  final int? live;
  final int? closed;

  AuditionsStats({
    required this.total,
    required this.byCraft,
    this.live,
    this.closed,
  });

  factory AuditionsStats.fromJson(Map<String, dynamic> json) {
    return AuditionsStats(
      total: _toInt(json['total']),
      byCraft: _toNameCountList(json['byCraft']),
      live: json['live'] != null ? _toInt(json['live']) : null,
      closed: json['closed'] != null ? _toInt(json['closed']) : null,
    );
  }
}

// ─── Applications ─────────────────────────────────────────────────────────────

class ApplicationsStats {
  final int total;

  ApplicationsStats({required this.total});

  factory ApplicationsStats.fromJson(Map<String, dynamic> json) {
    return ApplicationsStats(total: _toInt(json['total']));
  }
}

// ─── Content ──────────────────────────────────────────────────────────────────

class ContentStats {
  final int totalMediaPosts;
  final int? imagePosts;
  final int? videoPosts;
  final int stories;
  final int activeStories;
  final int videoViews;
  final int storyViews;
  final int? reach;
  final int? profileViews;

  ContentStats({
    required this.totalMediaPosts,
    this.imagePosts,
    this.videoPosts,
    required this.stories,
    required this.activeStories,
    required this.videoViews,
    required this.storyViews,
    this.reach,
    this.profileViews,
  });

  factory ContentStats.fromJson(Map<String, dynamic> json) {
    return ContentStats(
      totalMediaPosts: _toInt(json['totalMediaPosts']),
      imagePosts:
          json['imagePosts'] != null ? _toInt(json['imagePosts']) : null,
      videoPosts:
          json['videoPosts'] != null ? _toInt(json['videoPosts']) : null,
      stories: _toInt(json['stories']),
      activeStories: _toInt(json['activeStories']),
      videoViews: _toInt(json['videoViews']),
      storyViews: _toInt(json['storyViews']),
      reach: json['reach'] != null ? _toInt(json['reach']) : null,
      profileViews:
          json['profileViews'] != null ? _toInt(json['profileViews']) : null,
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class NameCount {
  final String name;
  final int count;

  NameCount({required this.name, required this.count});

  factory NameCount.fromJson(Map<String, dynamic> json) {
    return NameCount(
      name: json['name']?.toString() ?? '',
      count: _toInt(json['count']),
    );
  }
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

List<NameCount> _toNameCountList(dynamic raw) {
  if (raw is! List) return [];
  return raw
      .whereType<Map<String, dynamic>>()
      .map((e) => NameCount.fromJson(e))
      .toList();
}

Map<String, int> _toStringIntMap(dynamic raw) {
  if (raw is! Map) return {};
  return raw.map((k, v) => MapEntry(k.toString(), _toInt(v)));
}
