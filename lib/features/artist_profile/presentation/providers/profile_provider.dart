import 'package:flutter/foundation.dart';
import 'package:aicc/core/api/api_endpoints.dart';
import 'package:aicc/core/di/injection_container.dart';
import 'package:aicc/core/network/dio_client.dart';
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

  String? _myActivePlan;
  String? get myActivePlan => _myActivePlan ?? _currentProfile?.plan;

  List<PortfolioModel> _viewedMedia = [];
  List<PortfolioModel> get viewedMedia => _viewedMedia;

  List<PortfolioModel> _myMedia = [];
  List<PortfolioModel> get myMedia => _myMedia;

  void setActivePlan(String? plan) {
    _myActivePlan = plan;
    if (_currentProfile != null && plan != null) {
      _currentProfile = _currentProfile!.copyWith(
        plan: plan,
        isVerified: true,
      );
    }
    notifyListeners();
  }

  Future<String?> _fetchMySubscriptionPlan() async {
    try {
      if (sl.isRegistered<DioClient>()) {
        final dio = sl<DioClient>();
        final response = await dio.get(ApiEndpoints.subscriptionsMe);
        if (response.statusCode == 200 && response.data != null) {
          final data = response.data is Map ? response.data as Map : null;
          final subMap = data?['subscription'];
          final plan = data?['plan'] ??
              data?['currentPlan'] ??
              data?['activePlan'] ??
              (subMap is Map ? subMap['plan'] : null);
          if (plan != null &&
              plan.toString().trim().isNotEmpty &&
              plan.toString().trim().toLowerCase() != 'free') {
            return plan.toString().trim().toLowerCase();
          }
        }
      }
    } catch (_) {}
    return null;
  }

  Future<void> fetchMyProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getProfileMe(),
        _fetchMySubscriptionPlan(),
      ]);

      _currentProfile = results[0] as ArtistModel;
      final fetchedPlan = results[1] as String?;

      if (fetchedPlan != null && fetchedPlan.isNotEmpty) {
        _myActivePlan = fetchedPlan;
        _currentProfile = _currentProfile?.copyWith(
          plan: fetchedPlan,
          isVerified: true,
        );
      } else if (_currentProfile?.plan != null &&
          _currentProfile!.plan!.isNotEmpty) {
        _myActivePlan = _currentProfile!.plan;
      }
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
    if (_viewedProfile != null && _viewedProfile!.id == id) {
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
      if (_viewedProfile != null && _viewedProfile!.id == id) {
        _viewedProfile = previous;
        _error = e.toString();
        notifyListeners();
      }
      rethrow;
    }
  }

  void syncFollowStatus(String id, {required bool following}) {
    if (_viewedProfile != null && _viewedProfile!.id == id) {
      if (_viewedProfile!.following != following) {
        final currentCount = int.tryParse(_viewedProfile!.followers) ?? 0;
        final updatedCount = following
            ? currentCount + 1
            : (currentCount > 0 ? currentCount - 1 : 0);
        _viewedProfile = _viewedProfile!.copyWith(
          following: following,
          followers: updatedCount.toString(),
        );
        notifyListeners();
      }
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

  void clear() {
    _currentProfile = null;
    _viewedProfile = null;
    _myActivePlan = null;
    _myMedia = [];
    _viewedMedia = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
