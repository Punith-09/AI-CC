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

    return PortfolioModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      image: image,
      videoUrl: json['videoUrl']?.toString() ?? json['video']?.toString() ?? (isVid ? image : null),
      title: json['title']?.toString(),
      description: (json['desc'] ?? json['description'])?.toString(),
      likesCount: json['likesCount'] is int
          ? json['likesCount']
          : (int.tryParse(json['likesCount']?.toString() ?? '') ?? 0),
      viewsCount: json['viewsCount'] is int
          ? json['viewsCount']
          : (int.tryParse(json['viewsCount']?.toString() ?? '') ?? 0),
      liked: json['liked'] == true,
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