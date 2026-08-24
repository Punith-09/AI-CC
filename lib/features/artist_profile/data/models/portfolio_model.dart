import 'package:flutter/foundation.dart';

@immutable
class PortfolioModel {
  final String id;
  final String image;
  final String? videoUrl;
  final String? title;
  final bool isVideo;

  const PortfolioModel({
    this.id = '',
    required this.image,
    this.videoUrl,
    this.title,
    this.isVideo = false,
  });

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    final image = json['image']?.toString() ??
        json['url']?.toString() ??
        json['thumb']?.toString() ??
        json['thumbnail']?.toString() ??
        json['pic']?.toString() ??
        '';

    final isVid = json['is_video'] == true ||
        json['isVideo'] == true ||
        (json['url']?.toString().endsWith('.mp4') ?? false);

    return PortfolioModel(
      id: json['id']?.toString() ?? '',
      image: image,
      videoUrl: json['videoUrl']?.toString() ?? json['video']?.toString(),
      title: json['title']?.toString(),
      isVideo: isVid,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'videoUrl': videoUrl,
      'title': title,
      'is_video': isVideo,
    };
  }
}