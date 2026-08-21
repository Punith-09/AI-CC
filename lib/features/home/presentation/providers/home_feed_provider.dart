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
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
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
}
