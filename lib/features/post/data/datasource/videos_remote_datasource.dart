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
  }) async {
    MultipartFile multipartFile;

    if (fileBytes != null) {
      multipartFile = MultipartFile.fromBytes(
        fileBytes,
        filename: fileName,
      );
    } else if (!kIsWeb && filePath != null) {
      multipartFile = await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      );
    } else {
      throw Exception('No video file provided for upload.');
    }

    final formData = FormData.fromMap({
      'title': title,
      'category': category,
      'description': description,
      'file': multipartFile,
    });

    final response = await _dioClient.post(
      ApiEndpoints.videos,
      data: formData,
    );

    if (response.data is Map<String, dynamic>) {
      return VideoModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Invalid server response format for video upload');
    }
  }
}
