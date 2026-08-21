import '../../../../core/api/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../post/data/models/photo_model.dart';
import '../../../post/data/models/video_model.dart';
import '../models/comment_model.dart';
import '../models/feed_post_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<PhotoModel>> getPhotos();
  Future<List<VideoModel>> getVideos();
  Future<List<FeedPostModel>> getFeedPosts();
  Future<Map<String, dynamic>> toggleLike({required String id, required bool isVideo});
  Future<List<CommentModel>> getComments(String videoId);
  Future<CommentModel> postComment({required String videoId, required String text});
  Future<Map<String, dynamic>> toggleCommentLike(String commentId);
  Future<void> incrementVideoView(String videoId);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final DioClient _dioClient;

  HomeRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<PhotoModel>> getPhotos() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.photos);

      dynamic listData;
      if (response.data is List) {
        listData = response.data;
      } else if (response.data is Map && (response.data as Map).containsKey('data')) {
        listData = (response.data as Map)['data'];
      } else if (response.data is Map && (response.data as Map).containsKey('photos')) {
        listData = (response.data as Map)['photos'];
      } else {
        listData = [];
      }

      if (listData is List) {
        return listData
            .map((json) => PhotoModel.fromJson(Map<String, dynamic>.from(json as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<VideoModel>> getVideos() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.videos);

      dynamic listData;
      if (response.data is List) {
        listData = response.data;
      } else if (response.data is Map && (response.data as Map).containsKey('data')) {
        listData = (response.data as Map)['data'];
      } else if (response.data is Map && (response.data as Map).containsKey('videos')) {
        listData = (response.data as Map)['videos'];
      } else {
        listData = [];
      }

      if (listData is List) {
        return listData
            .map((json) => VideoModel.fromJson(Map<String, dynamic>.from(json as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<FeedPostModel>> getFeedPosts() async {
    final results = await Future.wait([
      getPhotos(),
      getVideos(),
    ]);

    final photos = results[0] as List<PhotoModel>;
    final videos = results[1] as List<VideoModel>;

    final List<FeedPostModel> rawFeed = [
      ...photos.map(FeedPostModel.fromPhotoModel),
      ...videos.map(FeedPostModel.fromVideoModel),
    ];

    // Deduplicate by unique ID and mediaUrl
    final Set<String> seenIds = {};
    final Set<String> seenUrls = {};
    final List<FeedPostModel> uniqueFeed = [];

    for (final post in rawFeed) {
      final hasId = post.id.isNotEmpty;
      final hasUrl = post.mediaUrl.isNotEmpty;

      if (hasId && seenIds.contains(post.id)) {
        continue; // Skip duplicate ID
      }
      if (hasUrl && seenUrls.contains(post.mediaUrl)) {
        continue; // Skip duplicate URL
      }

      if (hasId) seenIds.add(post.id);
      if (hasUrl) seenUrls.add(post.mediaUrl);
      uniqueFeed.add(post);
    }

    // Sort chronologically (newest first)
    uniqueFeed.sort((a, b) {
      if (a.createdAt == null && b.createdAt == null) return 0;
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      try {
        final dateA = DateTime.parse(a.createdAt!);
        final dateB = DateTime.parse(b.createdAt!);
        return dateB.compareTo(dateA);
      } catch (_) {
        return 0;
      }
    });

    return uniqueFeed;
  }

  @override
  Future<Map<String, dynamic>> toggleLike({
    required String id,
    required bool isVideo,
  }) async {
    try {
      final endpoint = isVideo ? ApiEndpoints.likeVideo(id) : ApiEndpoints.likePhoto(id);
      final response = await _dioClient.post(endpoint);

      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      return {};
    } catch (e) {
      if (!isVideo) {
        try {
          final response = await _dioClient.post(ApiEndpoints.likeVideo(id));
          if (response.data is Map) {
            return Map<String, dynamic>.from(response.data as Map);
          }
        } catch (_) {}
      }
      rethrow;
    }
  }

  @override
  Future<List<CommentModel>> getComments(String videoId) async {
    try {
      final response = await _dioClient.get(ApiEndpoints.videoComments(videoId));

      dynamic listData;
      if (response.data is List) {
        listData = response.data;
      } else if (response.data is Map && (response.data as Map).containsKey('data')) {
        listData = (response.data as Map)['data'];
      } else if (response.data is Map && (response.data as Map).containsKey('comments')) {
        listData = (response.data as Map)['comments'];
      } else {
        listData = [];
      }

      if (listData is List) {
        return listData
            .map((json) => CommentModel.fromJson(Map<String, dynamic>.from(json as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<CommentModel> postComment({
    required String videoId,
    required String text,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.videoComments(videoId),
      data: {'text': text},
    );

    if (response.data is Map) {
      final map = Map<String, dynamic>.from(response.data as Map);
      if (map.containsKey('data') && map['data'] is Map) {
        return CommentModel.fromJson(Map<String, dynamic>.from(map['data'] as Map));
      }
      return CommentModel.fromJson(map);
    }
    return CommentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      profileImage: '',
      username: 'You',
      comment: text,
      time: 'Just now',
      likes: 0,
      isLiked: false,
    );
  }

  @override
  Future<Map<String, dynamic>> toggleCommentLike(String commentId) async {
    try {
      final response = await _dioClient.post(ApiEndpoints.likeComment(commentId));
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      return {};
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> incrementVideoView(String videoId) async {
    try {
      await _dioClient.post(ApiEndpoints.viewVideo(videoId));
    } catch (_) {}
  }
}
