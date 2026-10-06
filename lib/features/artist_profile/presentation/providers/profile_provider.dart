import 'package:flutter/foundation.dart';
import 'package:aicc/core/api/api_endpoints.dart';
import 'package:aicc/core/di/injection_container.dart';
import 'package:aicc/core/network/dio_client.dart';
import 'package:aicc/core/storage/local_storage.dart';
import 'package:aicc/features/artist_profile/data/models/artist_model.dart';
import 'package:aicc/features/artist_profile/data/models/portfolio_model.dart';
import 'package:aicc/features/artist_profile/data/repository/profile_repository.dart';
import 'package:aicc/features/subscription/presentation/providers/subscription_provider.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileRepository _repository;

  ProfileProvider(this._repository) {
    _loadPersistedFollows();
  }

  final Set<String> _followingUserIds = {};
  final Set<String> _followLoadingUserIds = {};

  Set<String> get followingUserIds => Set.unmodifiable(_followingUserIds);

  void _loadPersistedFollows([String? userId]) {
    try {
      final saved = LocalStorage.instance.getFollowingUserIds(userId);
      _followingUserIds.clear();
      if (saved.isNotEmpty) {
        _followingUserIds.addAll(saved);
      }
    } catch (_) {}
  }

  void loadPersistedFollowsForUser([String? userId]) {
    _loadPersistedFollows(userId);
    notifyListeners();
  }

  String? get _loggedInUserId {
    if (_currentProfile?.id.isNotEmpty == true) return _currentProfile!.id;
    try {
      return LocalStorage.instance.getUserId();
    } catch (_) {
      return null;
    }
  }

  bool isFollowing(String? userId) {
    if (userId == null || userId.isEmpty) return false;
    return _followingUserIds.contains(userId);
  }

  bool isFollowLoading(String? userId) {
    if (userId == null || userId.isEmpty) return false;
    return _followLoadingUserIds.contains(userId);
  }

  void recordFollowing(String userId, bool following) {
    if (userId.isEmpty) return;
    final changed = following
        ? _followingUserIds.add(userId)
        : _followingUserIds.remove(userId);
    if (changed) {
      LocalStorage.instance.saveFollowingUserIds(_followingUserIds, _loggedInUserId);
      notifyListeners();
    }
  }

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
    if (plan != null && sl.isRegistered<SubscriptionProvider>()) {
      sl<SubscriptionProvider>().setActivePlan(plan);
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
          if (sl.isRegistered<SubscriptionProvider>()) {
            sl<SubscriptionProvider>().fetchSubscription(silent: true);
          }
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
        // Load persisted follows for this specific logged-in user
        final saved = LocalStorage.instance.getFollowingUserIds(_currentProfile!.id);
        _followingUserIds.clear();
        if (saved.isNotEmpty) {
          _followingUserIds.addAll(saved);
        }
        if (_currentProfile!.followingIds.isNotEmpty) {
          _followingUserIds.addAll(_currentProfile!.followingIds);
          LocalStorage.instance.saveFollowingUserIds(_followingUserIds, _currentProfile!.id);
        }

        final serverFollowing = int.tryParse(_currentProfile!.followingCount) ?? 0;
        final actualFollowing = serverFollowing > _followingUserIds.length
            ? serverFollowing
            : _followingUserIds.length;
        _currentProfile = _currentProfile!.copyWith(
          followingCount: actualFollowing.toString(),
        );

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
      if (_viewedProfile != null) {
        if (_viewedProfile!.following) {
          _followingUserIds.add(id);
          LocalStorage.instance.saveFollowingUserIds(_followingUserIds, _loggedInUserId);
        } else if (!_followLoadingUserIds.contains(id)) {
          // If server says not following and no toggle is in-flight, ensure local set matches
          if (_followingUserIds.contains(id)) {
            _followingUserIds.remove(id);
            LocalStorage.instance.saveFollowingUserIds(_followingUserIds, _loggedInUserId);
          }
        }
      }
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

  Future<bool> toggleFollowUser(String userId, {String? userName}) async {
    if (userId.isEmpty || _followLoadingUserIds.contains(userId)) {
      return isFollowing(userId);
    }

    _followLoadingUserIds.add(userId);
    notifyListeners();

    final bool willFollow = !_followingUserIds.contains(userId);

    // Optimistically update follow set
    if (willFollow) {
      _followingUserIds.add(userId);
    } else {
      _followingUserIds.remove(userId);
    }
    LocalStorage.instance.saveFollowingUserIds(_followingUserIds, _loggedInUserId);

    // Update target viewed profile if currently viewed
    if (_viewedProfile != null && _viewedProfile!.id == userId) {
      final currentCount = int.tryParse(_viewedProfile!.followers) ?? 0;
      final newCount = willFollow
          ? currentCount + 1
          : (currentCount > 0 ? currentCount - 1 : 0);
      _viewedProfile = _viewedProfile!.copyWith(
        following: willFollow,
        followers: newCount.toString(),
      );
    }

    // Update logged-in user profile (my following count)
    if (_currentProfile != null) {
      final myFollowing = int.tryParse(_currentProfile!.followingCount) ?? 0;
      final newMyFollowing = willFollow
          ? myFollowing + 1
          : (myFollowing > 0 ? myFollowing - 1 : 0);
      _currentProfile = _currentProfile!.copyWith(
        followingCount: newMyFollowing.toString(),
      );
    }

    notifyListeners();

    try {
      final serverResult = await _repository.followUser(userId);
      if (serverResult != null && serverResult != willFollow) {
        if (serverResult) {
          _followingUserIds.add(userId);
        } else {
          _followingUserIds.remove(userId);
        }
        LocalStorage.instance.saveFollowingUserIds(_followingUserIds, _loggedInUserId);

        if (_viewedProfile != null && _viewedProfile!.id == userId) {
          _viewedProfile = _viewedProfile!.copyWith(following: serverResult);
        }
        notifyListeners();
      }
      return _followingUserIds.contains(userId);
    } catch (e) {
      // Revert optimistic updates
      if (willFollow) {
        _followingUserIds.remove(userId);
      } else {
        _followingUserIds.add(userId);
      }
      LocalStorage.instance.saveFollowingUserIds(_followingUserIds, _loggedInUserId);

      if (_viewedProfile != null && _viewedProfile!.id == userId) {
        final currentCount = int.tryParse(_viewedProfile!.followers) ?? 0;
        final revertedCount = willFollow
            ? (currentCount > 0 ? currentCount - 1 : 0)
            : currentCount + 1;
        _viewedProfile = _viewedProfile!.copyWith(
          following: !willFollow,
          followers: revertedCount.toString(),
        );
      }

      if (_currentProfile != null) {
        final myFollowing = int.tryParse(_currentProfile!.followingCount) ?? 0;
        final revertedMyFollowing = willFollow
            ? (myFollowing > 0 ? myFollowing - 1 : 0)
            : myFollowing + 1;
        _currentProfile = _currentProfile!.copyWith(
          followingCount: revertedMyFollowing.toString(),
        );
      }

      _error = e.toString();
      rethrow;
    } finally {
      _followLoadingUserIds.remove(userId);
      notifyListeners();
    }
  }

  Future<void> followUser(String id) async {
    await toggleFollowUser(id);
  }

  void syncFollowStatus(String id, {required bool following}) {
    if (id.isEmpty) return;
    if (following) {
      _followingUserIds.add(id);
    } else {
      _followingUserIds.remove(id);
    }
    LocalStorage.instance.saveFollowingUserIds(_followingUserIds, _loggedInUserId);

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
      }
    }

    if (_currentProfile != null) {
      final myFollowing = int.tryParse(_currentProfile!.followingCount) ?? 0;
      final newMyFollowing = following
          ? myFollowing + 1
          : (myFollowing > 0 ? myFollowing - 1 : 0);
      _currentProfile = _currentProfile!.copyWith(
        followingCount: newMyFollowing.toString(),
      );
    }

    notifyListeners();
  }

  /// Immediately updates the profile image URL in local state (optimistic).
  /// Does NOT call the API — use [updateProfile] separately to persist.
  void updateProfilePhotoLocally(String url) {
    if (url.isEmpty) return;
    if (_currentProfile != null) {
      _currentProfile = _currentProfile!.copyWith(profileImage: url);
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final existingImageUrl = _currentProfile?.profileImage ?? '';
    final requestedPhoto = (data['profilePhoto'] ??
            data['profile_image'] ??
            data['profileImage'] ??
            data['pic'] ??
            data['avatar'])
        ?.toString();

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _repository.updateProfile(data);

      String finalPhotoUrl = updated.profileImage;
      if (finalPhotoUrl.isEmpty) {
        if (requestedPhoto != null && requestedPhoto.isNotEmpty) {
          finalPhotoUrl = requestedPhoto;
        } else {
          finalPhotoUrl = existingImageUrl;
        }
      }

      _currentProfile = updated.copyWith(profileImage: finalPhotoUrl);
      if (finalPhotoUrl.isNotEmpty) {
        try {
          LocalStorage.instance.saveUserProfilePhoto(finalPhotoUrl);
        } catch (_) {}
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _followingUserIds.clear();
    _followLoadingUserIds.clear();
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
