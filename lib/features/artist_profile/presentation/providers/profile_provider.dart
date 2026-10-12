import 'package:flutter/foundation.dart';
import 'package:aicc/core/api/api_endpoints.dart';
import 'package:aicc/core/di/injection_container.dart';
import 'package:aicc/core/network/dio_client.dart';
import 'package:aicc/core/storage/local_storage.dart';
import 'package:aicc/features/artist_profile/data/models/artist_model.dart';
import 'package:aicc/features/artist_profile/data/models/portfolio_model.dart';
import 'package:aicc/features/artist_profile/data/models/profile_completion_model.dart';
import 'package:aicc/features/artist_profile/data/repository/profile_repository.dart';
import 'package:aicc/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:aicc/features/home/presentation/providers/home_feed_provider.dart';

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

  ProfileCompletionModel? _completion;
  ProfileCompletionModel? get completion => _completion;

  int get completionPercentage => _completion?.percentage ?? 0;
  bool get isProfileCompleted => (_completion?.percentage ?? 0) >= 100;

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

  Future<void> fetchMyProfile({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

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
        for (final item in fetchedMedia) {
          if (!combined.any((m) => areDuplicates(m, item))) {
            combined.add(item);
          }
        }
        // Preserve any newly added local posts that might not yet be returned by getUserMedia
        for (final m in _myMedia) {
          if (!combined.any((item) => areDuplicates(item, m))) {
            combined.add(m);
          }
        }
        if (_currentProfile?.portfolio.isNotEmpty == true) {
          for (final p in _currentProfile!.portfolio) {
            if (!combined.any((item) => areDuplicates(item, p))) {
              combined.add(p);
            }
          }
        }
        _myMedia = deduplicateMedia(combined);
        _currentProfile = _currentProfile!.copyWith(projects: _myMedia.length);
      } else {
        _myMedia = deduplicateMedia(_currentProfile?.portfolio ?? []);
      }

      try {
        _completion = await _repository.getProfileCompletion();
      } catch (_) {}
    } catch (e) {
      if (!silent) {
        _error = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Helper to clean media URLs for exact matching across formats
  static String cleanMediaKey(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    String clean = url.split('?').first.split('#').first.trim().toLowerCase();
    final uri = Uri.tryParse(clean);
    if (uri != null && uri.path.isNotEmpty) {
      clean = uri.path;
    }
    while (clean.startsWith('/')) {
      clean = clean.substring(1);
    }
    return clean;
  }

  /// Returns true if two PortfolioModel items represent the same underlying post
  static bool areDuplicates(PortfolioModel a, PortfolioModel b) {
    // 1. If both have valid non-empty IDs, compare IDs directly
    if (a.id.isNotEmpty && b.id.isNotEmpty) {
      return a.id == b.id;
    }

    final aVid = cleanMediaKey(a.videoUrl);
    final bVid = cleanMediaKey(b.videoUrl);

    // 2. If both are videos: compare videoUrl ONLY (never compare thumbnail image!)
    if (a.isVideo && b.isVideo) {
      if (aVid.isNotEmpty && bVid.isNotEmpty) {
        return aVid == bVid;
      }
      return false;
    }

    // 3. If both are photos: compare image URL
    if (!a.isVideo && !b.isVideo) {
      final aImg = cleanMediaKey(a.image);
      final bImg = cleanMediaKey(b.image);
      if (aImg.isNotEmpty && bImg.isNotEmpty) {
        return aImg == bImg;
      }
      return false;
    }

    // 4. One is video, one is photo: they are only duplicates if photo URL matches the video URL
    final aImg = cleanMediaKey(a.image);
    final bImg = cleanMediaKey(b.image);
    if (a.isVideo && !b.isVideo) {
      if (aVid.isNotEmpty && bImg.isNotEmpty && aVid == bImg) return true;
    }
    if (!a.isVideo && b.isVideo) {
      if (aImg.isNotEmpty && bVid.isNotEmpty && aImg == bVid) return true;
    }

    return false;
  }

  /// Removes all duplicates from a list of PortfolioModel items
  static List<PortfolioModel> deduplicateMedia(List<PortfolioModel> list) {
    final List<PortfolioModel> unique = [];
    for (final item in list) {
      final isDup = unique.any((existing) => areDuplicates(existing, item));
      if (!isDup) {
        unique.add(item);
      }
    }
    return unique;
  }

  /// Instantly adds an uploaded post to the current user's gallery in memory
  /// so it reflects immediately without requiring a manual refresh.
  void addPortfolioItem(PortfolioModel item) {
    final exists = _myMedia.any((m) => areDuplicates(m, item));
    if (!exists) {
      _myMedia = [item, ..._myMedia];
    }

    if (_currentProfile != null) {
      final updatedPortfolio = List<PortfolioModel>.from(_currentProfile!.portfolio);
      final pExists = updatedPortfolio.any((m) => areDuplicates(m, item));
      if (!pExists) {
        updatedPortfolio.insert(0, item);
      }
      _currentProfile = _currentProfile!.copyWith(
        portfolio: updatedPortfolio,
        projects: _myMedia.length,
      );
    }

    notifyListeners();

    // Silently sync from backend in the background
    fetchMyProfile(silent: true);
  }

  Future<void> fetchProfileCompletion() async {
    try {
      _completion = await _repository.getProfileCompletion();
      notifyListeners();
    } catch (_) {}
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
      try {
        final fetchedMedia = await _repository.getUserMedia(id);
        for (final item in fetchedMedia) {
          if (!combined.any((m) => areDuplicates(m, item))) {
            combined.add(item);
          }
        }
      } catch (_) {
        // Profile still renders if photos/videos endpoints fail.
      }
      if (_viewedProfile?.portfolio.isNotEmpty == true) {
        for (final p in _viewedProfile!.portfolio) {
          if (!combined.any((item) => areDuplicates(item, p))) {
            combined.add(p);
          }
        }
      }
      _viewedMedia = deduplicateMedia(combined);
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

      if (_currentProfile != null) {
        _currentProfile = _currentProfile!.copyWith(
          name: updated.name.isNotEmpty ? updated.name : _currentProfile!.name,
          stageName: updated.stageName.isNotEmpty ? updated.stageName : _currentProfile!.stageName,
          email: updated.email.isNotEmpty ? updated.email : _currentProfile!.email,
          mobile: updated.mobile.isNotEmpty ? updated.mobile : _currentProfile!.mobile,
          gender: updated.gender.isNotEmpty ? updated.gender : _currentProfile!.gender,
          dob: updated.dob.isNotEmpty ? updated.dob : _currentProfile!.dob,
          country: updated.country.isNotEmpty ? updated.country : _currentProfile!.country,
          state: updated.state.isNotEmpty ? updated.state : _currentProfile!.state,
          city: updated.city.isNotEmpty ? updated.city : _currentProfile!.city,
          profileImage: finalPhotoUrl,
          roles: updated.roles.isNotEmpty ? updated.roles : _currentProfile!.roles,
          skills: updated.skills.isNotEmpty ? updated.skills : _currentProfile!.skills,
          experience: updated.experience.isNotEmpty ? updated.experience : _currentProfile!.experience,
          languages: updated.languages.isNotEmpty ? updated.languages : _currentProfile!.languages,
          preferredLanguages: updated.preferredLanguages.isNotEmpty ? updated.preferredLanguages : _currentProfile!.preferredLanguages,
          awards: updated.awards > 0 ? updated.awards : _currentProfile!.awards,
          projects: updated.projects > 0 ? updated.projects : _currentProfile!.projects,
          followers: updated.followers.isNotEmpty && updated.followers != '0' ? updated.followers : _currentProfile!.followers,
          followingCount: updated.followingCount.isNotEmpty && updated.followingCount != '0' ? updated.followingCount : _currentProfile!.followingCount,
        );
      } else {
        _currentProfile = updated.copyWith(profileImage: finalPhotoUrl);
      }
      if (finalPhotoUrl.isNotEmpty) {
        try {
          LocalStorage.instance.saveUserProfilePhoto(finalPhotoUrl);
        } catch (_) {}
      }

      try {
        _completion = await _repository.getProfileCompletion();
      } catch (_) {}
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePost({required String id, required bool isVideo}) async {
    try {
      final success = await _repository.deletePost(id: id, isVideo: isVideo);
      if (success) {
        _myMedia.removeWhere((item) => item.id == id);
        _viewedMedia.removeWhere((item) => item.id == id);

        if (_currentProfile != null) {
          final updatedPortfolio =
              _currentProfile!.portfolio.where((item) => item.id != id).toList();
          final currentProjects = _currentProfile!.projects;
          _currentProfile = _currentProfile!.copyWith(
            portfolio: updatedPortfolio,
            projects: currentProjects > 0 ? currentProjects - 1 : 0,
          );
        }

        if (sl.isRegistered<HomeFeedProvider>()) {
          sl<HomeFeedProvider>().removePost(id);
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting post: $e');
      rethrow;
    }
  }

  void clear() {
    _followingUserIds.clear();
    _followLoadingUserIds.clear();
    _currentProfile = null;
    _completion = null;
    _viewedProfile = null;
    _myActivePlan = null;
    _myMedia = [];
    _viewedMedia = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
