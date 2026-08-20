import 'dart:typed_data';

import '../datasource/photos_remote_datasource.dart';
import '../models/photo_model.dart';

abstract class PhotosRepository {
  Future<PhotoModel> uploadPhoto({
    required String title,
    required String description,
    required String fileName,
    String? filePath,
    Uint8List? fileBytes,
  });
}

class PhotosRepositoryImpl implements PhotosRepository {
  final PhotosRemoteDataSource _remoteDataSource;

  PhotosRepositoryImpl(this._remoteDataSource);

  @override
  Future<PhotoModel> uploadPhoto({
    required String title,
    required String description,
    required String fileName,
    String? filePath,
    Uint8List? fileBytes,
  }) async {
    return await _remoteDataSource.uploadPhoto(
      title: title,
      description: description,
      fileName: fileName,
      filePath: filePath,
      fileBytes: fileBytes,
    );
  }
}
