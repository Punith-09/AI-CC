import 'package:flutter/foundation.dart';

@immutable
class PostModel {
  final String id;
  final String profileImage;
  final String userName;
  final String location;
  final bool isVerified;
  final String postImage;
  final String caption;
  final String hashtags;
  final String likes;
  final String time;

  const PostModel({
    this.id = '',
    required this.profileImage,
    required this.userName,
    required this.location,
    required this.isVerified,
    required this.postImage,
    required this.caption,
    required this.hashtags,
    required this.likes,
    required this.time,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String? ?? '',
      profileImage: json['profile_image'] as String? ?? '',
      userName: json['user_name'] as String? ?? '',
      location: json['location'] as String? ?? '',
      isVerified: json['is_verified'] as bool? ?? false,
      postImage: json['post_image'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
      hashtags: json['hashtags'] as String? ?? '',
      likes: json['likes'] as String? ?? '0',
      time: json['time'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'profile_image': profileImage,
        'user_name': userName,
        'location': location,
        'is_verified': isVerified,
        'post_image': postImage,
        'caption': caption,
        'hashtags': hashtags,
        'likes': likes,
        'time': time,
      };
}