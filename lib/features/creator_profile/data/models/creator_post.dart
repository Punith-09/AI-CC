import 'package:flutter/foundation.dart';

@immutable
class CreatorPost {
  final String id;
  final String image;
  final int likes;

  const CreatorPost({
    this.id = '',
    required this.image,
    required this.likes,
  });

  factory CreatorPost.fromJson(Map<String, dynamic> json) {
    return CreatorPost(
      id: json['id'] as String? ?? '',
      image: json['image'] as String? ?? '',
      likes: json['likes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'image': image,
        'likes': likes,
      };
}
