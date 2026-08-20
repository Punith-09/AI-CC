import 'package:flutter/foundation.dart';

import '../../data/models/video_model.dart';
import '../../data/repository/videos_repository.dart';

class VideosProvider extends ChangeNotifier {
  final VideosRepository _videosRepository;

  VideosProvider(this._videosRepository);

  bool _isUploading = false;
  String? _errorMessage;
  VideoModel? _uploadedVideo;

  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;
  VideoModel? get uploadedVideo => _uploadedVideo;

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
    notifyListeners();

    try {
      final video = await _videosRepository.uploadVideo(
        title: title,
        category: category,
        description: description,
        fileName: fileName,
        filePath: filePath,
        fileBytes: fileBytes,
      );
      _uploadedVideo = video;
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
    _uploadedVideo = null;
  }
}
