import 'package:flutter/foundation.dart';

@immutable
class CommentModel {
  final String id;
  final String profileImage;
  final String username;
  final String comment;
  final String time;
  final int likes;
  final bool isVerified;
  final bool isLiked;

  const CommentModel({
    this.id = '',
    required this.profileImage,
    required this.username,
    required this.comment,
    required this.time,
    required this.likes,
    this.isVerified = false,
    this.isLiked = false,
  });

  CommentModel copyWith({
    String? id,
    String? profileImage,
    String? username,
    String? comment,
    String? time,
    int? likes,
    bool? isVerified,
    bool? isLiked,
  }) {
    return CommentModel(
      id: id ?? this.id,
      profileImage: profileImage ?? this.profileImage,
      username: username ?? this.username,
      comment: comment ?? this.comment,
      time: time ?? this.time,
      likes: likes ?? this.likes,
      isVerified: isVerified ?? this.isVerified,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String? ?? '',
      profileImage: json['profile_image'] as String? ?? '',
      username: json['username'] as String? ?? '',
      comment: json['comment'] as String? ?? '',
      time: json['time'] as String? ?? '',
      likes: json['likes'] as int? ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'profile_image': profileImage,
        'username': username,
        'comment': comment,
        'time': time,
        'likes': likes,
        'is_verified': isVerified,
        'is_liked': isLiked,
      };
}
