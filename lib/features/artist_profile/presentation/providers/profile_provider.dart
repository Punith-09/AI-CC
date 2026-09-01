import 'package:flutter/foundation.dart';
import 'package:aicc/features/artist_profile/data/models/artist_model.dart';
import 'package:aicc/features/artist_profile/data/models/portfolio_model.dart';
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

  List<PortfolioModel> _viewedMedia = [];
  List<PortfolioModel> get viewedMedia => _viewedMedia;

  List<PortfolioModel> _myMedia = [];
  List<PortfolioModel> get myMedia => _myMedia;

  Future<void> fetchMyProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentProfile = await _repository.getProfileMe();
      if (_currentProfile?.id != null && _currentProfile!.id.isNotEmpty) {
        final fetchedMedia = await _repository.getUserMedia(_currentProfile!.id);
        final combined = <PortfolioModel>[];
        if (_currentProfile?.portfolio.isNotEmpty == true) {
          combined.addAll(_currentProfile!.portfolio);
        }
        for (final m in fetchedMedia) {
          if (!combined.any((item) => item.image == m.image || (item.id.isNotEmpty && item.id == m.id))) {
            combined.add(m);
          }
        }
        _myMedia = combined;
      } else {
        _myMedia = _currentProfile?.portfolio ?? [];
      }
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
    _viewedMedia = [];
    notifyListeners();

    try {
      _viewedProfile = await _repository.getUserProfile(id);
      final combined = <PortfolioModel>[];
      if (_viewedProfile?.portfolio.isNotEmpty == true) {
        combined.addAll(_viewedProfile!.portfolio);
      }
      try {
        final fetchedMedia = await _repository.getUserMedia(id);
        for (final m in fetchedMedia) {
          if (!combined.any((item) => item.image == m.image || (item.id.isNotEmpty && item.id == m.id))) {
            combined.add(m);
          }
        }
      } catch (_) {
        // Profile still renders if photos/videos endpoints fail.
      }
      _viewedMedia = combined;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> followUser(String id) async {
    final previous = _viewedProfile;
    if (_viewedProfile != null) {
      final currentFollowing = _viewedProfile!.following;
      final currentCount = int.tryParse(_viewedProfile!.followers) ?? 0;
      final updatedCount = currentFollowing
          ? (currentCount > 0 ? currentCount - 1 : 0)
          : currentCount + 1;

      _viewedProfile = _viewedProfile!.copyWith(
        following: !currentFollowing,
        followers: updatedCount.toString(),
      );
      notifyListeners();
    }

    try {
      await _repository.followUser(id);
    } catch (e) {
      _viewedProfile = previous;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentProfile = await _repository.updateProfile(data);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
