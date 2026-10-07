import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/video_model.dart';

abstract class VideosRemoteDataSource {
  Future<VideoModel> uploadVideo({
    required String title,
    required String category,
    required String description,
    required String fileName,
    String? filePath,
    Uint8List? fileBytes,
    void Function(double progress)? onProgress,
  });
}

class VideosRemoteDataSourceImpl implements VideosRemoteDataSource {
  final DioClient _dioClient;

  VideosRemoteDataSourceImpl(this._dioClient);

  @override
  Future<VideoModel> uploadVideo({
    required String title,
    required String category,
    required String description,
    required String fileName,
    String? filePath,
    Uint8List? fileBytes,
    void Function(double progress)? onProgress,
  }) async {
    MultipartFile mediaFile;
    if (fileBytes != null) {
      mediaFile = MultipartFile.fromBytes(fileBytes, filename: fileName);
    } else if (!kIsWeb && filePath != null && filePath.isNotEmpty) {
      mediaFile = await MultipartFile.fromFile(filePath, filename: fileName);
    } else {
      throw Exception('No video file provided for upload.');
    }

    final formData = FormData.fromMap({
      'file': mediaFile,
      'title': title,
      'description': description,
      'category': category,
    });

    final response = await _dioClient.post(
      ApiEndpoints.uploadVideo,
      data: formData,
      onSendProgress: (sent, total) {
        if (total > 0 && onProgress != null) {
          onProgress(sent / total);
        }
      },
    );

    if (response.data is Map<String, dynamic>) {
      final map = response.data as Map<String, dynamic>;
      if (map.containsKey('data') && map['data'] is Map<String, dynamic>) {
        return VideoModel.fromJson(map['data'] as Map<String, dynamic>);
      }
      return VideoModel.fromJson(map);
    } else if (response.data is Map) {
      final map = Map<String, dynamic>.from(response.data as Map);
      if (map.containsKey('data') && map['data'] is Map) {
        return VideoModel.fromJson(Map<String, dynamic>.from(map['data'] as Map));
      }
      return VideoModel.fromJson(map);
    } else {
      throw Exception('Invalid server response format for video creation.');
    }
  }
}
