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
    // ─── Step 1: Upload the raw video file to cloud storage via /media/upload ───
    // This avoids hitting Vercel's 4.5 MB serverless body-size limit.
    // On native platforms we stream directly from the file path (no RAM spike).
    // On web we fall back to bytes.
    MultipartFile mediaFile;
    if (!kIsWeb && filePath != null) {
      mediaFile = await MultipartFile.fromFile(filePath, filename: fileName);
    } else if (fileBytes != null) {
      mediaFile = MultipartFile.fromBytes(fileBytes, filename: fileName);
    } else {
      throw Exception('No video file provided for upload.');
    }

    final mediaFormData = FormData.fromMap({'file': mediaFile});

    // Upload progress: step 1 occupies 0 → 0.9 of the reported progress range
    final mediaRes = await _dioClient.post(
      ApiEndpoints.mediaUpload,
      data: mediaFormData,
      onSendProgress: (sent, total) {
        if (total > 0 && onProgress != null) {
          // Map byte progress to 0 – 90 % so step-2 leaves headroom
          onProgress((sent / total) * 0.9);
        }
      },
    );

    // ─── Extract the uploaded video URL ───────────────────────────────────────
    String? videoUrl;
    if (mediaRes.data is Map) {
      final map = Map<String, dynamic>.from(mediaRes.data as Map);
      videoUrl = map['url'] as String? ??
          map['videoUrl'] as String? ??
          map['path'] as String? ??
          map['file'] as String? ??
          map['location'] as String? ??
          map['link'] as String? ??
          (map['data'] is Map
              ? (map['data']['url'] ??
                      map['data']['videoUrl'] ??
                      map['data']['path'] ??
                      map['data']['file'] ??
                      map['data']['location'])
                  ?.toString()
              : null);
    }

    if (videoUrl == null || videoUrl.isEmpty) {
      throw Exception('Media upload succeeded but no URL was returned by the server.');
    }

    onProgress?.call(0.95);

    // ─── Step 2: Register video metadata + URL with the backend ───────────────
    final metaResponse = await _dioClient.post(
      ApiEndpoints.uploadVideo,
      data: {
        'title': title,
        'category': category,
        'description': description,
        'url': videoUrl,
      },
    );

    onProgress?.call(1.0);

    if (metaResponse.data is Map<String, dynamic>) {
      final map = metaResponse.data as Map<String, dynamic>;
      if (map.containsKey('data') && map['data'] is Map<String, dynamic>) {
        return VideoModel.fromJson(map['data'] as Map<String, dynamic>);
      }
      return VideoModel.fromJson(map);
    } else if (metaResponse.data is Map) {
      final map = Map<String, dynamic>.from(metaResponse.data as Map);
      if (map.containsKey('data') && map['data'] is Map) {
        return VideoModel.fromJson(Map<String, dynamic>.from(map['data'] as Map));
      }
      return VideoModel.fromJson(map);
    } else {
      throw Exception('Invalid server response format for video creation.');
    }
  }
}
