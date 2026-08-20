import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/photo_model.dart';

abstract class PhotosRemoteDataSource {
  Future<PhotoModel> uploadPhoto({
    required String title,
    required String description,
    required String fileName,
    String? filePath,
    Uint8List? fileBytes,
  });
}

class PhotosRemoteDataSourceImpl implements PhotosRemoteDataSource {
  final DioClient _dioClient;

  PhotosRemoteDataSourceImpl(this._dioClient);

  @override
  Future<PhotoModel> uploadPhoto({
    required String title,
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
      throw Exception('No photo file provided for upload.');
    }

    final formData = FormData.fromMap({
      'title': title,
      'description': description,
      'file': multipartFile,
    });

    final response = await _dioClient.post(
      ApiEndpoints.photos,
      data: formData,
    );

    if (response.data is Map<String, dynamic>) {
      return PhotoModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Invalid server response format for photo upload');
    }
  }
}
