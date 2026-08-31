import '../../../post/data/models/photo_model.dart';
import '../../../post/data/models/video_model.dart';

enum FeedMediaType {
  photo,
  video,
}

class FeedPostModel {
  final String id;
  final FeedMediaType type;
  final String title;
  final String description;
  final String mediaUrl;
  final String? thumbnailUrl;
  final String? category;
  final String? creatorId;
  final String creatorName;
  final String? creatorPic;
  final String? creatorCategory;
  final int likesCount;
  final int commentsCount;
  final int viewsCount;
  final bool liked;
  final String? createdAt;
  final String? hashtags;
  final String location;
  final bool isVerified;

  const FeedPostModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.mediaUrl,
    this.thumbnailUrl,
    this.category,
    this.creatorId,
    required this.creatorName,
    this.creatorPic,
    this.creatorCategory,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.viewsCount = 0,
    this.liked = false,
    this.createdAt,
    this.hashtags,
    this.location = '',
    this.isVerified = true,
  });

  bool get isVideo => type == FeedMediaType.video;
  bool get isPhoto => type == FeedMediaType.photo;

  FeedPostModel copyWith({
    String? id,
    FeedMediaType? type,
    String? title,
    String? description,
    String? mediaUrl,
    String? thumbnailUrl,
    String? category,
    String? creatorId,
    String? creatorName,
    String? creatorPic,
    String? creatorCategory,
    int? likesCount,
    int? commentsCount,
    int? viewsCount,
    bool? liked,
    String? createdAt,
    String? hashtags,
    String? location,
    bool? isVerified,
  }) {
    return FeedPostModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      category: category ?? this.category,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      creatorPic: creatorPic ?? this.creatorPic,
      creatorCategory: creatorCategory ?? this.creatorCategory,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      viewsCount: viewsCount ?? this.viewsCount,
      liked: liked ?? this.liked,
      createdAt: createdAt ?? this.createdAt,
      hashtags: hashtags ?? this.hashtags,
      location: location ?? this.location,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  String get timeAgo {
    if (createdAt == null || createdAt!.isEmpty) {
      return 'RECENT';
    }
    try {
      final created = DateTime.parse(createdAt!);
      final diff = DateTime.now().difference(created);

      if (diff.inMinutes < 1) return 'JUST NOW';
      if (diff.inMinutes < 60) return '${diff.inMinutes}M AGO';
      if (diff.inHours < 24) return '${diff.inHours} HOURS AGO';
      if (diff.inDays == 1) return 'YESTERDAY';
      if (diff.inDays < 7) return '${diff.inDays} DAYS AGO';
      return '${created.day}/${created.month}/${created.year}';
    } catch (_) {
      return createdAt!;
    }
  }

  factory FeedPostModel.fromPhotoModel(PhotoModel photo) {
    final rawUrl = photo.url.toLowerCase();
    final isVideo = rawUrl.endsWith('.mp4') ||
        rawUrl.endsWith('.mov') ||
        rawUrl.contains('/video/upload/');

    String photoLocation = '';
    if (photo.location != null && photo.location!.trim().isNotEmpty) {
      photoLocation = photo.location!.trim();
    } else if (photo.city != null && photo.city!.trim().isNotEmpty) {
      if (photo.state != null && photo.state!.trim().isNotEmpty) {
        photoLocation = '${photo.city!.trim()}, ${photo.state!.trim()}';
      } else {
        photoLocation = photo.city!.trim();
      }
    } else if (photo.state != null && photo.state!.trim().isNotEmpty) {
      photoLocation = photo.state!.trim();
    }

    return FeedPostModel(
      id: photo.id,
      type: isVideo ? FeedMediaType.video : FeedMediaType.photo,
      title: photo.title,
      description: photo.desc ?? '',
      mediaUrl: photo.url,
      thumbnailUrl: photo.thumb ?? (isVideo ? null : photo.url),
      category: photo.category,
      creatorId: photo.creatorId,
      creatorName: (photo.creatorName != null && photo.creatorName!.isNotEmpty)
          ? photo.creatorName!
          : 'Creator',
      creatorPic: photo.creatorPic,
      creatorCategory: photo.creatorCategory ?? 'Artist',
      likesCount: photo.likesCount,
      commentsCount: 0,
      viewsCount: photo.viewsCount,
      liked: photo.liked,
      createdAt: photo.createdAt,
      hashtags: photo.category != null ? '#${photo.category} #Portfolio' : '#Portfolio',
      location: photoLocation,
    );
  }

  factory FeedPostModel.fromVideoModel(VideoModel video) {
    String videoLocation = '';
    if (video.location != null && video.location!.trim().isNotEmpty) {
      videoLocation = video.location!.trim();
    } else if (video.city != null && video.city!.trim().isNotEmpty) {
      if (video.state != null && video.state!.trim().isNotEmpty) {
        videoLocation = '${video.city!.trim()}, ${video.state!.trim()}';
      } else {
        videoLocation = video.city!.trim();
      }
    } else if (video.state != null && video.state!.trim().isNotEmpty) {
      videoLocation = video.state!.trim();
    }

    return FeedPostModel(
      id: video.id,
      type: FeedMediaType.video,
      title: video.title,
      description: video.desc ?? '',
      mediaUrl: video.url,
      thumbnailUrl: video.thumb ?? video.url,
      category: video.category,
      creatorId: video.creatorId,
      creatorName: (video.creatorName != null && video.creatorName!.isNotEmpty)
          ? video.creatorName!
          : 'Creator',
      creatorPic: video.creatorPic,
      creatorCategory: video.creatorCategory ?? 'Actor',
      likesCount: video.likesCount,
      commentsCount: 0,
      viewsCount: video.viewsCount,
      liked: video.liked,
      createdAt: video.createdAt,
      hashtags: video.category != null ? '#${video.category} #Reel' : '#Reel #Acting',
      location: videoLocation,
    );
  }

  factory FeedPostModel.fromJson(Map<String, dynamic> json, {FeedMediaType? defaultType}) {
    final rawUrl = json['url'] as String? ?? '';
    final isVideoUrl = rawUrl.toLowerCase().endsWith('.mp4') ||
        rawUrl.toLowerCase().endsWith('.mov') ||
        rawUrl.toLowerCase().contains('/video/');

    final mediaType = defaultType ??
        (isVideoUrl ? FeedMediaType.video : FeedMediaType.photo);

    final creatorMap = json['creator'] is Map
        ? json['creator'] as Map<String, dynamic>
        : (json['user'] is Map ? json['user'] as Map<String, dynamic> : null);

    final rawLocation = json['location'] ?? json['creatorLocation'] ?? creatorMap?['location'];
    final rawCity = json['city'] ?? json['creatorCity'] ?? creatorMap?['city'];
    final rawState = json['state'] ?? json['creatorState'] ?? creatorMap?['state'];

    String resolvedLocation = '';
    if (rawLocation != null && rawLocation.toString().trim().isNotEmpty) {
      resolvedLocation = rawLocation.toString().trim();
    } else if (rawCity != null && rawCity.toString().trim().isNotEmpty) {
      if (rawState != null && rawState.toString().trim().isNotEmpty) {
        resolvedLocation = '${rawCity.toString().trim()}, ${rawState.toString().trim()}';
      } else {
        resolvedLocation = rawCity.toString().trim();
      }
    } else if (rawState != null && rawState.toString().trim().isNotEmpty) {
      resolvedLocation = rawState.toString().trim();
    }

    return FeedPostModel(
      id: json['id'] as String? ?? '',
      type: mediaType,
      title: json['title'] as String? ?? '',
      description: (json['desc'] ?? json['description']) as String? ?? '',
      mediaUrl: rawUrl,
      thumbnailUrl: json['thumb'] as String? ?? (isVideoUrl ? null : rawUrl),
      creatorId: json['creatorId'] as String? ??
          json['userId'] as String? ??
          json['user_id'] as String? ??
          json['creator_id'] as String? ??
          (json['creator'] is String ? json['creator'] as String : null) ??
          (json['user'] is String ? json['user'] as String : null) ??
          creatorMap?['_id']?.toString() ??
          creatorMap?['id']?.toString(),
      creatorName: json['creatorName'] as String? ?? creatorMap?['fullName'] as String? ?? creatorMap?['name'] as String? ?? 'Creator',
      creatorPic: json['creatorPic'] as String? ?? creatorMap?['profilePhoto'] as String? ?? creatorMap?['avatar'] as String?,
      creatorCategory: json['creatorCategory'] as String? ?? creatorMap?['role'] as String? ?? creatorMap?['category'] as String? ?? 'Artist',
      likesCount: json['likesCount'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      viewsCount: json['viewsCount'] as int? ?? 0,
      liked: json['liked'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
      hashtags: json['category'] != null ? '#${json['category']}' : '#AICC',
      location: resolvedLocation,
    );
  }
}
