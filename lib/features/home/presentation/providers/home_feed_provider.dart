import 'package:flutter/material.dart';
import '../../data/models/feed_post_model.dart';
import '../../data/repository/home_repository.dart';
import '../../../../core/di/injection_container.dart';
import '../../../artist_profile/data/repository/profile_repository.dart';
import '../../../artist_profile/presentation/providers/profile_provider.dart';

class HomeFeedProvider extends ChangeNotifier {
  final HomeRepository _homeRepository;

  HomeFeedProvider(this._homeRepository);

  List<FeedPostModel> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Video Pagination State
  List<FeedPostModel> _videoPosts = [];
  bool _isVideoLoading = false;
  bool _isLoadingMoreVideos = false;
  bool _hasMoreVideos = true;
  String? _videoErrorMessage;
  int _videoOffset = 0;
  bool _hasFetchedVideos = false;
  static const int _videoPageSize = 4;

  List<FeedPostModel> get posts => _posts;
  List<FeedPostModel> get imagePosts => _posts.where((p) => p.isPhoto).toList();
  List<FeedPostModel> get videoPosts => _hasFetchedVideos
      ? _videoPosts
      : (_videoPosts.isNotEmpty ? _videoPosts : _posts.where((p) => p.isVideo).toList());
  List<FeedPostModel> get paginatedVideos => _videoPosts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isVideoLoading => _isVideoLoading;
  bool get isLoadingMoreVideos => _isLoadingMoreVideos;
  bool get hasMoreVideos => _hasMoreVideos;
  String? get videoErrorMessage => _videoErrorMessage;
  bool get hasFetchedVideos => _hasFetchedVideos;
  int get videoOffset => _videoOffset;

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

  /// Initial or pull-to-refresh load for vertical Reels/Videos screen
  Future<void> fetchVideos({bool isRefresh = false}) async {
    if (_isVideoLoading) return;

    _hasFetchedVideos = true;
    _isVideoLoading = true;
    _videoErrorMessage = null;
    if (isRefresh) {
      _hasMoreVideos = true;
      _videoOffset = 0;
    }
    notifyListeners();

    try {
      const int limit = _videoPageSize;
      const int offset = 0;
      final videos = await _homeRepository.getVideosFeed(limit: limit, offset: offset);

      final Set<String> seenIds = {};
      final List<FeedPostModel> deduped = [];
      for (final v in videos) {
        if (v.id.isNotEmpty) {
          if (!seenIds.add(v.id)) continue;
        }
        deduped.add(v);
      }

      _videoPosts = deduped;
      _videoOffset = videos.length;
      _hasMoreVideos = videos.length >= limit;
      _isVideoLoading = false;
      _videoErrorMessage = null;
      notifyListeners();

      _fetchVideoCommentCounts(deduped);
    } catch (e) {
      _isVideoLoading = false;
      _videoErrorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  /// Triggered when near end of reels list for infinite loading
  Future<void> fetchMoreVideos() async {
    if (_isVideoLoading || _isLoadingMoreVideos || !_hasMoreVideos) {
      return;
    }

    _isLoadingMoreVideos = true;
    notifyListeners();

    try {
      const int limit = _videoPageSize;
      final int offset = _videoOffset;
      final newVideos = await _homeRepository.getVideosFeed(limit: limit, offset: offset);

      if (newVideos.isEmpty) {
        _hasMoreVideos = false;
        _isLoadingMoreVideos = false;
        notifyListeners();
        return;
      }

      final existingIds = _videoPosts.map((v) => v.id).where((id) => id.isNotEmpty).toSet();
      final List<FeedPostModel> toAppend = [];
      for (final v in newVideos) {
        if (v.id.isEmpty || !existingIds.contains(v.id)) {
          if (v.id.isNotEmpty) existingIds.add(v.id);
          toAppend.add(v);
        }
      }

      _videoPosts.addAll(toAppend);
      _videoOffset += newVideos.length;
      if (newVideos.length < limit) {
        _hasMoreVideos = false;
      }

      _isLoadingMoreVideos = false;
      notifyListeners();

      if (toAppend.isNotEmpty) {
        _fetchVideoCommentCounts(toAppend);
      }
    } catch (e) {
      _isLoadingMoreVideos = false;
      notifyListeners();
    }
  }

  void _fetchVideoCommentCounts(List<FeedPostModel> videos) {
    for (final v in videos) {
      if (v.id.isNotEmpty) {
        _fetchOneVideoCommentCount(v.id);
      }
    }
  }

  Future<void> _fetchOneVideoCommentCount(String videoId) async {
    try {
      final count = await _homeRepository.getCommentsCount(videoId);
      final index = _videoPosts.indexWhere((p) => p.id == videoId);
      if (index != -1) {
        _videoPosts[index] = _videoPosts[index].copyWith(commentsCount: count);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> toggleLike(String postId, {BuildContext? context}) async {
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    final videoIndex = _videoPosts.indexWhere((p) => p.id == postId);
    if (postIndex == -1 && videoIndex == -1) return;

    final originalPost = postIndex != -1 ? _posts[postIndex] : _videoPosts[videoIndex];
    final bool newLiked = !originalPost.liked;

    final int newLikesCount = newLiked
        ? originalPost.likesCount + 1
        : (originalPost.likesCount > 0 ? originalPost.likesCount - 1 : 0);

    // Optimistic Update
    if (postIndex != -1) {
      _posts[postIndex] = _posts[postIndex].copyWith(
        liked: newLiked,
        likesCount: newLikesCount,
      );
    }
    if (videoIndex != -1) {
      _videoPosts[videoIndex] = _videoPosts[videoIndex].copyWith(
        liked: newLiked,
        likesCount: newLikesCount,
      );
    }
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

      if (postIndex != -1) {
        _posts[postIndex] = _posts[postIndex].copyWith(
          liked: serverLiked,
          likesCount: serverLikesCount,
        );
      }
      if (videoIndex != -1) {
        _videoPosts[videoIndex] = _videoPosts[videoIndex].copyWith(
          liked: serverLiked,
          likesCount: serverLikesCount,
        );
      }
      notifyListeners();
    } catch (e) {
      // Revert optimistic update on failure
      if (postIndex != -1) {
        _posts[postIndex] = originalPost;
      }
      if (videoIndex != -1) {
        _videoPosts[videoIndex] = originalPost;
      }
      notifyListeners();
    }
  }


  final Set<String> _followingUserIds = {};
  final Set<String> _followLoadingUserIds = {};

  bool isFollowing(String? userId) {
    if (userId == null || userId.isEmpty) return false;
    if (sl.isRegistered<ProfileProvider>()) {
      return sl<ProfileProvider>().isFollowing(userId);
    }
    return _followingUserIds.contains(userId);
  }

  bool isFollowLoading(String? userId) {
    if (userId == null || userId.isEmpty) return false;
    if (sl.isRegistered<ProfileProvider>()) {
      return sl<ProfileProvider>().isFollowLoading(userId);
    }
    return _followLoadingUserIds.contains(userId);
  }

  void syncFollowStatus(String userId, {required bool following}) {
    if (userId.isEmpty) return;
    if (following) {
      _followingUserIds.add(userId);
    } else {
      _followingUserIds.remove(userId);
    }
    if (sl.isRegistered<ProfileProvider>()) {
      sl<ProfileProvider>().recordFollowing(userId, following);
    }
    notifyListeners();
  }

  Future<bool> toggleFollowUser(String userId) async {
    if (userId.isEmpty) return false;
    if (sl.isRegistered<ProfileProvider>()) {
      final res = await sl<ProfileProvider>().toggleFollowUser(userId);
      notifyListeners();
      return res;
    }

    if (_followLoadingUserIds.contains(userId)) {
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

      return isNowFollowing;
    } catch (e) {
      _followLoadingUserIds.remove(userId);
      notifyListeners();
      rethrow;
    }
  }

  /// Syncs like state for a post across screens
  void syncPostLike(String postId, {required bool liked, required int likesCount}) {
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    final videoIndex = _videoPosts.indexWhere((p) => p.id == postId);

    if (postIndex != -1) {
      _posts[postIndex] = _posts[postIndex].copyWith(
        liked: liked,
        likesCount: likesCount,
      );
    }
    if (videoIndex != -1) {
      _videoPosts[videoIndex] = _videoPosts[videoIndex].copyWith(
        liked: liked,
        likesCount: likesCount,
      );
    }
    if (postIndex != -1 || videoIndex != -1) {
      notifyListeners();
    }
  }

  /// Called by CommentsBottomSheet after loading comments so the
  /// feed card icon counter reflects the real server count.
  void updateCommentsCount(String postId, int count) {
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    final videoIndex = _videoPosts.indexWhere((p) => p.id == postId);

    if (postIndex != -1) {
      _posts[postIndex] = _posts[postIndex].copyWith(commentsCount: count);
    }
    if (videoIndex != -1) {
      _videoPosts[videoIndex] = _videoPosts[videoIndex].copyWith(commentsCount: count);
    }
    if (postIndex != -1 || videoIndex != -1) {
      notifyListeners();
    }
  }

  /// Removes a deleted post from the feed
  void removePost(String postId) {
    final pLen = _posts.length;
    _posts.removeWhere((p) => p.id == postId);
    final vLen = _videoPosts.length;
    _videoPosts.removeWhere((p) => p.id == postId);
    if (_posts.length != pLen || _videoPosts.length != vLen) {
      notifyListeners();
    }
  }

  /// Clears all state when the user logs out, so the next logged-in user
  /// starts with a clean feed and follow state.
  void clear() {
    _posts = [];
    _isLoading = false;
    _errorMessage = null;
    _followingUserIds.clear();
    _followLoadingUserIds.clear();
    _videoPosts = [];
    _isVideoLoading = false;
    _isLoadingMoreVideos = false;
    _hasMoreVideos = true;
    _videoErrorMessage = null;
    _videoOffset = 0;
    _hasFetchedVideos = false;
    notifyListeners();
  }
}

