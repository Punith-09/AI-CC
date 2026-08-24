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
        _myMedia = await _repository.getUserMedia(_currentProfile!.id);
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
      final results = await Future.wait([
        _repository.getUserProfile(id),
        _repository.getUserMedia(id),
      ]);

      _viewedProfile = results[0] as ArtistModel;
      final fetchedMedia = results[1] as List<PortfolioModel>;

      // Combine profile portfolio items and fetched media
      final combined = <PortfolioModel>[];
      if (_viewedProfile?.portfolio.isNotEmpty == true) {
        combined.addAll(_viewedProfile!.portfolio);
      }
      for (final m in fetchedMedia) {
        if (!combined.any((item) => item.image == m.image)) {
          combined.add(m);
        }
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
    try {
      await _repository.followUser(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
