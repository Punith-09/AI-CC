import 'package:flutter/foundation.dart';
import '../../../../features/home/data/models/feed_post_model.dart';
import 'artist_model.dart';

@immutable
class PortfolioModel {
  final String id;
  final String image;
  final String? videoUrl;
  final String? title;
  final String? description;
  final int likesCount;
  final int viewsCount;
  final bool liked;
  final String? createdAt;
  final bool isVideo;

  const PortfolioModel({
    this.id = '',
    required this.image,
    this.videoUrl,
    this.title,
    this.description,
    this.likesCount = 0,
    this.viewsCount = 0,
    this.liked = false,
    this.createdAt,
    this.isVideo = false,
  });

  PortfolioModel copyWith({
    String? id,
    String? image,
    String? videoUrl,
    String? title,
    String? description,
    int? likesCount,
    int? viewsCount,
    bool? liked,
    String? createdAt,
    bool? isVideo,
  }) {
    return PortfolioModel(
      id: id ?? this.id,
      image: image ?? this.image,
      videoUrl: videoUrl ?? this.videoUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      likesCount: likesCount ?? this.likesCount,
      viewsCount: viewsCount ?? this.viewsCount,
      liked: liked ?? this.liked,
      createdAt: createdAt ?? this.createdAt,
      isVideo: isVideo ?? this.isVideo,
    );
  }

  FeedPostModel toFeedPostModel({ArtistModel? artist}) {
    final media = (videoUrl != null && videoUrl!.isNotEmpty) ? videoUrl! : image;
    return FeedPostModel(
      id: id.isNotEmpty ? id : 'portfolio_${image.hashCode}',
      type: isVideo ? FeedMediaType.video : FeedMediaType.photo,
      title: title ?? (isVideo ? 'Video' : 'Photo'),
      description: description ?? '',
      mediaUrl: media,
      thumbnailUrl: image,
      category: artist?.roles.isNotEmpty == true ? artist!.roles.first : 'Portfolio',
      creatorId: artist?.id ?? '',
      creatorName: artist?.name.isNotEmpty == true ? artist!.name : 'Creator',
      creatorPic: artist?.profileImage,
      creatorCategory: artist?.roles.isNotEmpty == true ? artist!.roles.first : 'Artist',
      likesCount: likesCount,
      commentsCount: 0,
      viewsCount: viewsCount,
      liked: liked,
      createdAt: createdAt,
      hashtags: artist?.roles.isNotEmpty == true ? '#${artist!.roles.first} #Portfolio' : '#Portfolio',
      location: artist != null
          ? (artist.city.isNotEmpty && artist.state.isNotEmpty
              ? '${artist.city}, ${artist.state}'
              : (artist.city.isNotEmpty ? artist.city : artist.state))
          : '',
    );
  }

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    final image = json['image']?.toString() ??
        json['url']?.toString() ??
        json['thumb']?.toString() ??
        json['thumbnail']?.toString() ??
        json['pic']?.toString() ??
        '';

    final isVid = json['is_video'] == true ||
        json['isVideo'] == true ||
        (json['url']?.toString().toLowerCase().endsWith('.mp4') ?? false) ||
        (json['url']?.toString().toLowerCase().endsWith('.mov') ?? false) ||
        (json['videoUrl'] != null && json['videoUrl'].toString().isNotEmpty) ||
        (json['video'] != null && json['video'].toString().isNotEmpty);

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

    return PortfolioModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      image: image,
      videoUrl: json['videoUrl']?.toString() ?? json['video']?.toString() ?? (isVid ? image : null),
      title: json['title']?.toString(),
      description: (json['desc'] ?? json['description'])?.toString(),
      likesCount: parsedLikesCount,
      viewsCount: parsedViewsCount,
      liked: isLiked,
      createdAt: (json['createdAt'] ?? json['created_at'])?.toString(),
      isVideo: isVid,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'videoUrl': videoUrl,
      'title': title,
      'description': description,
      'likesCount': likesCount,
      'viewsCount': viewsCount,
      'liked': liked,
      'createdAt': createdAt,
      'is_video': isVideo,
    };
  }
}