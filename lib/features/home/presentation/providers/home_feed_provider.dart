import 'package:flutter/material.dart';
import '../../data/models/feed_post_model.dart';
import '../../data/repository/home_repository.dart';

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

  Future<void> toggleLike(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final originalPost = _posts[index];
    final bool newLiked = !originalPost.liked;
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

      final serverLiked = res['liked'] as bool? ?? newLiked;
      final serverLikesCount = res['likesCount'] as int? ?? newLikesCount;

      _posts[index] = _posts[index].copyWith(
        liked: serverLiked,
        likesCount: serverLikesCount,
      );
      notifyListeners();
    } catch (e) {
      // Revert optimistic update on failure
      _posts[index] = originalPost;
      notifyListeners();
    }
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
