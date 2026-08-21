import '../datasource/home_remote_datasource.dart';
import '../models/comment_model.dart';
import '../models/feed_post_model.dart';

abstract class HomeRepository {
  Future<List<FeedPostModel>> getFeed();
  Future<Map<String, dynamic>> toggleLike({required String id, required bool isVideo});
  Future<List<CommentModel>> getComments(String videoId);
  Future<CommentModel> postComment({required String videoId, required String text});
  Future<Map<String, dynamic>> toggleCommentLike(String commentId);
  Future<void> incrementVideoView(String videoId);
}

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;

  HomeRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<FeedPostModel>> getFeed() async {
    return await _remoteDataSource.getFeedPosts();
  }

  @override
  Future<Map<String, dynamic>> toggleLike({
    required String id,
    required bool isVideo,
  }) async {
    return await _remoteDataSource.toggleLike(id: id, isVideo: isVideo);
  }

  @override
  Future<List<CommentModel>> getComments(String videoId) async {
    return await _remoteDataSource.getComments(videoId);
  }

  @override
  Future<CommentModel> postComment({
    required String videoId,
    required String text,
  }) async {
    return await _remoteDataSource.postComment(videoId: videoId, text: text);
  }

  @override
  Future<Map<String, dynamic>> toggleCommentLike(String commentId) async {
    return await _remoteDataSource.toggleCommentLike(commentId);
  }

  @override
  Future<void> incrementVideoView(String videoId) async {
    return await _remoteDataSource.incrementVideoView(videoId);
  }
}
