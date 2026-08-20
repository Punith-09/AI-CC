import 'package:flutter/foundation.dart';
import 'package:aicc/features/artist_profile/data/models/artist_model.dart';
import 'package:aicc/features/artist_profile/data/repository/profile_repository.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileRepository _repository;

  ProfileProvider(this._repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  ArtistModel? _currentProfile;
  ArtistModel? get currentProfile => _currentProfile;
  ArtistModel? _viewedProfile;
  ArtistModel? get viewedProfile => _viewedProfile;

  Future<void> fetchMyProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentProfile = await _repository.getProfileMe();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserProfile(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _viewedProfile = await _repository.getUserProfile(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> followUser(String id) async {
    try {
      await _repository.followUser(id);
      // Optionally update local state or re-fetch profile
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
