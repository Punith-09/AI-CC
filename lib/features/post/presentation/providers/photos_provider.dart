import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../data/models/photo_model.dart';
import '../../data/repository/photos_repository.dart';

class PhotosProvider extends ChangeNotifier {
  final PhotosRepository _photosRepository;

  PhotosProvider(this._photosRepository);

  bool _isUploading = false;
  String? _errorMessage;
  PhotoModel? _uploadedPhoto;

  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;
  PhotoModel? get uploadedPhoto => _uploadedPhoto;

  Future<bool> uploadPhoto({
    required String title,
    required String description,
    required String fileName,
    String? filePath,
    Uint8List? fileBytes,
  }) async {
    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final photo = await _photosRepository.uploadPhoto(
        title: title,
        description: description,
        fileName: fileName,
        filePath: filePath,
        fileBytes: fileBytes,
      );
      _uploadedPhoto = photo;
      _isUploading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  void clearState() {
    _isUploading = false;
    _errorMessage = null;
    _uploadedPhoto = null;
  }
}
