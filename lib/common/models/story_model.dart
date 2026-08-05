import 'package:flutter/foundation.dart';

@immutable
class StoryModel {
  final String id;
  final String image;
  final String name;
  final bool isLive;
  final bool isMine;

  const StoryModel({
    this.id = '',
    required this.image,
    required this.name,
    this.isLive = false,
    this.isMine = false,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] as String? ?? '',
      image: json['image'] as String? ?? '',
      name: json['name'] as String? ?? '',
      isLive: json['is_live'] as bool? ?? false,
      isMine: json['is_mine'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'image': image,
        'name': name,
        'is_live': isLive,
        'is_mine': isMine,
      };
}