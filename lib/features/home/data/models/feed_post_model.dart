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
    this.viewsCount = 0,
    this.liked = false,
    this.createdAt,
    this.hashtags,
    this.location = 'Mumbai, MH',
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
      viewsCount: photo.viewsCount,
      liked: photo.liked,
      createdAt: photo.createdAt,
      hashtags: photo.category != null ? '#${photo.category} #Portfolio' : '#Portfolio',
    );
  }

  factory FeedPostModel.fromVideoModel(VideoModel video) {
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
      viewsCount: video.viewsCount,
      liked: video.liked,
      createdAt: video.createdAt,
      hashtags: video.category != null ? '#${video.category} #Reel' : '#Reel #Acting',
    );
  }

  factory FeedPostModel.fromJson(Map<String, dynamic> json, {FeedMediaType? defaultType}) {
    final rawUrl = json['url'] as String? ?? '';
    final isVideoUrl = rawUrl.toLowerCase().endsWith('.mp4') ||
        rawUrl.toLowerCase().endsWith('.mov') ||
        rawUrl.toLowerCase().contains('/video/');

    final mediaType = defaultType ??
        (isVideoUrl ? FeedMediaType.video : FeedMediaType.photo);

    return FeedPostModel(
      id: json['id'] as String? ?? '',
      type: mediaType,
      title: json['title'] as String? ?? '',
      description: (json['desc'] ?? json['description']) as String? ?? '',
      mediaUrl: rawUrl,
      thumbnailUrl: json['thumb'] as String? ?? (isVideoUrl ? null : rawUrl),
      category: json['category'] as String?,
      creatorId: json['creatorId'] as String?,
      creatorName: json['creatorName'] as String? ?? 'Creator',
      creatorPic: json['creatorPic'] as String?,
      creatorCategory: json['creatorCategory'] as String? ?? 'Artist',
      likesCount: json['likesCount'] as int? ?? 0,
      viewsCount: json['viewsCount'] as int? ?? 0,
      liked: json['liked'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
      hashtags: json['category'] != null ? '#${json['category']}' : '#AICC',
    );
  }
}
