import 'package:flutter/foundation.dart';

import '../datasource/videos_remote_datasource.dart';
import '../models/video_model.dart';

abstract class VideosRepository {
  Future<VideoModel> uploadVideo({
    required String title,
    required String category,
    required String description,
    required String fileName,
    String? filePath,
    Uint8List? fileBytes,
  });
}

class VideosRepositoryImpl implements VideosRepository {
  final VideosRemoteDataSource _remoteDataSource;

  VideosRepositoryImpl(this._remoteDataSource);

  @override
  Future<VideoModel> uploadVideo({
    required String title,
    required String category,
    required String description,
    required String fileName,
    String? filePath,
    Uint8List? fileBytes,
  }) async {
    return await _remoteDataSource.uploadVideo(
      title: title,
      category: category,
      description: description,
      fileName: fileName,
      filePath: filePath,
      fileBytes: fileBytes,
    );
  }
}
