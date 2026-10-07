import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/video_model.dart';
import '../../data/repository/videos_repository.dart';

class VideosProvider extends ChangeNotifier {
  final VideosRepository _videosRepository;

  VideosProvider(this._videosRepository);

  bool _isUploading = false;
  String? _errorMessage;
  VideoModel? _uploadedVideo;
  double _uploadProgress = 0.0;

  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;
  VideoModel? get uploadedVideo => _uploadedVideo;
  double get uploadProgress => _uploadProgress;

  Future<bool> uploadVideo({
    required String title,
    required String category,
    required String description,
    required String fileName,
    String? filePath,
    Uint8List? fileBytes,
  }) async {
    _isUploading = true;
    _errorMessage = null;
    _uploadProgress = 0.0;
    notifyListeners();

    try {
      final video = await _videosRepository.uploadVideo(
        title: title,
        category: category,
        description: description,
        fileName: fileName,
        filePath: filePath,
        fileBytes: fileBytes,
        onProgress: (progress) {
          _uploadProgress = progress;
          notifyListeners();
        },
      );
      _uploadedVideo = video;
      _uploadProgress = 1.0;
      _isUploading = false;
      notifyListeners();
      return true;
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        final resData = e.response!.data;
        if (resData is Map && resData['message'] != null) {
          _errorMessage = resData['message'].toString();
        } else if (resData is Map && resData['error'] != null) {
          _errorMessage = resData['error'].toString();
        } else {
          _errorMessage = e.message ?? e.toString();
        }
      } else {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      }
      _isUploading = false;
      _uploadProgress = 0.0;
      notifyListeners();
      return false;
    }
  }

  void clearState() {
    _isUploading = false;
    _errorMessage = null;
    _uploadedVideo = null;
    _uploadProgress = 0.0;
  }
}
