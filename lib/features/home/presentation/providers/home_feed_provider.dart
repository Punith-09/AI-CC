import 'package:flutter/material.dart';
import '../../data/models/feed_post_model.dart';
import '../../data/repository/home_repository.dart';
import '../../../../core/di/injection_container.dart';
import '../../../artist_profile/data/repository/profile_repository.dart';
import '../../../artist_profile/presentation/providers/profile_provider.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../../subscription/presentation/widgets/limit_upgrade_dialog.dart';

class HomeFeedProvider extends ChangeNotifier {
  final HomeRepository _homeRepository;

  HomeFeedProvider(this._homeRepository);

  List<FeedPostModel> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<FeedPostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchFeed({bool isRefresh = false}) async {
    if (!isRefresh && _posts.isNotEmpty) {
      // Don't show full page spinner if we already have posts
    } else {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final feed = await _homeRepository.getFeed();
      _posts = feed;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();

      // Immediately kick off background comment-count fetches so the
      // counts are visible as soon as possible without blocking the feed.
      _fetchCommentCounts();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  /// Fires parallel requests for every post's comment count.
  /// Each resolves independently and updates just that card.
  void _fetchCommentCounts() {
    for (int i = 0; i < _posts.length; i++) {
      final postId = _posts[i].id;
      if (postId.isNotEmpty) {
        _fetchOneCommentCount(postId);
      }
    }
  }

  Future<void> _fetchOneCommentCount(String postId) async {
    try {
      final count = await _homeRepository.getCommentsCount(postId);
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        _posts[index] = _posts[index].copyWith(commentsCount: count);
        notifyListeners();
      }
    } catch (_) {
      // Silently ignore — count just stays at 0
    }
  }

  Future<void> refreshFeed() async {
    await fetchFeed(isRefresh: true);
  }

  Future<void> toggleLike(String postId, {BuildContext? context}) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final originalPost = _posts[index];
    final bool newLiked = !originalPost.liked;

    // If liking (not unliking), check quota
    if (newLiked && sl.isRegistered<SubscriptionProvider>()) {
      final sub = sl<SubscriptionProvider>();
      if (!sub.canLike) {
        if (context != null && context.mounted) {
          LimitUpgradeDialog.show(context, type: LimitType.like);
        }
        return;
      }
      sub.recordLikeUsed();
    }

    final int newLikesCount = newLiked
        ? originalPost.likesCount + 1
        : (originalPost.likesCount > 0 ? originalPost.likesCount - 1 : 0);

    // Optimistic Update
    _posts[index] = originalPost.copyWith(
      liked: newLiked,
      likesCount: newLikesCount,
    );
    notifyListeners();

    try {
      final res = await _homeRepository.toggleLike(
        id: postId,
        isVideo: originalPost.isVideo,
      );

      final serverLiked = res['liked'] as bool? ?? (res['data'] is Map ? res['data']['liked'] as bool? : null) ?? newLiked;
      final dynamic rawLikesCount = res['likesCount'] ?? res['data']?['likesCount'] ?? (res['likes'] is List ? (res['likes'] as List).length : null);
      int serverLikesCount = newLikesCount;
      if (rawLikesCount is int) {
        serverLikesCount = rawLikesCount;
      } else if (rawLikesCount is num) {
        serverLikesCount = rawLikesCount.toInt();
      } else if (rawLikesCount is String) {
        serverLikesCount = int.tryParse(rawLikesCount) ?? newLikesCount;
      }

      _posts[index] = _posts[index].copyWith(
        liked: serverLiked,
        likesCount: serverLikesCount,
      );
      notifyListeners();
    } catch (e) {
      // Revert optimistic update on failure
      _posts[index] = originalPost;
      notifyListeners();

      if (newLiked && sl.isRegistered<SubscriptionProvider>()) {
        final sub = sl<SubscriptionProvider>();
        final errStr = e.toString().toLowerCase();
        if (errStr.contains('limit') ||
            errStr.contains('quota') ||
            errStr.contains('upgrade') ||
            errStr.contains('429') ||
            errStr.contains('403')) {
          sub.markLimitReached(LimitType.like);
          if (context != null && context.mounted) {
            LimitUpgradeDialog.show(context, type: LimitType.like);
          }
        } else {
          sub.revertLikeUsed();
        }
      }
    }
  }


  final Set<String> _followingUserIds = {};
  final Set<String> _followLoadingUserIds = {};

  bool isFollowing(String? userId) {
    if (userId == null || userId.isEmpty) return false;
    return _followingUserIds.contains(userId);
  }

  bool isFollowLoading(String? userId) {
    if (userId == null || userId.isEmpty) return false;
    return _followLoadingUserIds.contains(userId);
  }

  void syncFollowStatus(String userId, {required bool following}) {
    if (userId.isEmpty) return;
    if (following) {
      _followingUserIds.add(userId);
    } else {
      _followingUserIds.remove(userId);
    }
    notifyListeners();
  }

  Future<bool> toggleFollowUser(String userId) async {
    if (userId.isEmpty || _followLoadingUserIds.contains(userId)) {
      return _followingUserIds.contains(userId);
    }

    _followLoadingUserIds.add(userId);
    notifyListeners();

    try {
      if (sl.isRegistered<ProfileRepository>()) {
        await sl<ProfileRepository>().followUser(userId);
      }
      final isNowFollowing = !_followingUserIds.contains(userId);
      if (isNowFollowing) {
        _followingUserIds.add(userId);
      } else {
        _followingUserIds.remove(userId);
      }
      _followLoadingUserIds.remove(userId);
      notifyListeners();

      if (sl.isRegistered<ProfileProvider>()) {
        sl<ProfileProvider>().syncFollowStatus(userId, following: isNowFollowing);
      }

      return isNowFollowing;
    } catch (e) {
      _followLoadingUserIds.remove(userId);
      notifyListeners();
      rethrow;
    }
  }

  /// Syncs like state for a post across screens
  void syncPostLike(String postId, {required bool liked, required int likesCount}) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;
    _posts[index] = _posts[index].copyWith(
      liked: liked,
      likesCount: likesCount,
    );
    notifyListeners();
  }

  /// Called by CommentsBottomSheet after loading comments so the
  /// feed card icon counter reflects the real server count.
  void updateCommentsCount(String postId, int count) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;
    _posts[index] = _posts[index].copyWith(commentsCount: count);
    notifyListeners();
  }
}

