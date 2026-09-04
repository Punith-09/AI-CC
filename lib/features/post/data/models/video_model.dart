class VideoModel {
  final String id;
  final String? category;
  final String? creatorId;
  final String? creatorName;
  final String? creatorPic;
  final String? creatorCategory;
  final String? location;
  final String? city;
  final String? state;
  final String title;
  final String? desc;
  final String url;
  final String? thumb;
  final int likesCount;
  final int viewsCount;
  final bool liked;
  final String? createdAt;

  VideoModel({
    required this.id,
    this.category,
    this.creatorId,
    this.creatorName,
    this.creatorPic,
    this.creatorCategory,
    this.location,
    this.city,
    this.state,
    required this.title,
    this.desc,
    required this.url,
    this.thumb,
    this.likesCount = 0,
    this.viewsCount = 0,
    this.liked = false,
    this.createdAt,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    final creatorMap = json['creator'] is Map
        ? json['creator'] as Map<String, dynamic>
        : (json['user'] is Map ? json['user'] as Map<String, dynamic> : null);

    final rawLikes = json['likes'];
    final rawLikesCount = json['likesCount'] ?? json['likes_count'] ?? json['likeCount'];
    int parsedLikesCount = 0;
    if (rawLikesCount is int) {
      parsedLikesCount = rawLikesCount;
    } else if (rawLikesCount is num) {
      parsedLikesCount = rawLikesCount.toInt();
    } else if (rawLikes is List) {
      parsedLikesCount = rawLikes.length;
    } else if (rawLikesCount is String) {
      parsedLikesCount = int.tryParse(rawLikesCount) ?? 0;
    }

    final rawViews = json['viewsCount'] ?? json['views_count'] ?? json['viewCount'] ?? json['views'];
    int parsedViewsCount = 0;
    if (rawViews is int) {
      parsedViewsCount = rawViews;
    } else if (rawViews is num) {
      parsedViewsCount = rawViews.toInt();
    } else if (rawViews is List) {
      parsedViewsCount = rawViews.length;
    } else if (rawViews is String) {
      parsedViewsCount = int.tryParse(rawViews) ?? 0;
    }

    final isLiked = json['liked'] == true || json['isLiked'] == true || json['is_liked'] == true;

    return VideoModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      creatorId: json['creatorId'] as String? ??
          json['userId'] as String? ??
          json['user_id'] as String? ??
          json['creator_id'] as String? ??
          (json['creator'] is String ? json['creator'] as String : null) ??
          (json['user'] is String ? json['user'] as String : null) ??
          creatorMap?['_id']?.toString() ??
          creatorMap?['id']?.toString(),
      creatorName: json['creatorName'] as String? ?? creatorMap?['fullName'] as String? ?? creatorMap?['name'] as String?,
      creatorPic: json['creatorPic'] as String? ?? creatorMap?['profilePhoto'] as String? ?? creatorMap?['avatar'] as String?,
      creatorCategory: json['creatorCategory'] as String? ?? creatorMap?['role'] as String? ?? creatorMap?['category'] as String?,
      location: json['location'] as String? ?? creatorMap?['location'] as String?,
      city: json['city'] as String? ?? json['creatorCity'] as String? ?? creatorMap?['city'] as String?,
      state: json['state'] as String? ?? json['creatorState'] as String? ?? creatorMap?['state'] as String?,
      title: json['title'] as String? ?? '',
      desc: (json['desc'] ?? json['description']) as String?,
      url: json['url'] as String? ?? '',
      thumb: json['thumb'] as String?,
      likesCount: parsedLikesCount,
      viewsCount: parsedViewsCount,
      liked: isLiked,
      createdAt: (json['createdAt'] ??
              json['created_at'] ??
              json['createdAtUtc'] ??
              json['creationDate'] ??
              json['creation_date'] ??
              json['timestamp'] ??
              json['time'] ??
              json['uploadedAt'] ??
              json['uploaded_at'] ??
              json['uploadDate'] ??
              json['upload_date'] ??
              json['date'])
          ?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'creatorPic': creatorPic,
      'creatorCategory': creatorCategory,
      'title': title,
      'desc': desc,
      'url': url,
      'thumb': thumb,
      'likesCount': likesCount,
      'viewsCount': viewsCount,
      'liked': liked,
      'createdAt': createdAt,
    };
  }
}
