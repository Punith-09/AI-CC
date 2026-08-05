import 'package:flutter/foundation.dart';

@immutable
class PortfolioModel {
  final String id;
  final String image;
  final bool isVideo;

  const PortfolioModel({
    this.id = '',
    required this.image,
    this.isVideo = false,
  });

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    return PortfolioModel(
      id: json['id'] as String? ?? '',
      image: json['image'] as String? ?? '',
      isVideo: json['is_video'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'image': image,
        'is_video': isVideo,
      };
}
