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

  factory PortfolioModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return PortfolioModel(
      id: json['id']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      isVideo: json['is_video'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'is_video': isVideo,
    };
  }
}