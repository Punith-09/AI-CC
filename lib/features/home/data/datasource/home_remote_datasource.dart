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
  Future<int> getCommentsCount(String videoId);
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

  Future<Map<String, dynamic>> _fetchUserLocations() async {
    final Map<String, String> locationMap = {};
    final Map<String, String> nameToIdMap = {};
    // id -> {name, pic, role}
    final Map<String, Map<String, String>> idToUser = {};
    try {
      final response = await _dioClient.get(ApiEndpoints.exploreUsers);
      dynamic listData;
      if (response.data is List) {
        listData = response.data;
      } else if (response.data is Map && (response.data as Map).containsKey('data')) {
        listData = (response.data as Map)['data'];
      } else if (response.data is Map && (response.data as Map).containsKey('users')) {
        listData = (response.data as Map)['users'];
      } else if (response.data is Map && (response.data as Map).containsKey('talents')) {
        listData = (response.data as Map)['talents'];
      }

      if (listData is List) {
        for (final item in listData) {
          if (item is Map) {
            final id = item['_id']?.toString() ?? item['id']?.toString();
            final name = item['fullName']?.toString() ?? item['name']?.toString() ?? item['username']?.toString();
            final pic = item['profileImage']?.toString() ??
                item['profilePhoto']?.toString() ??
                item['avatar']?.toString() ??
                item['pic']?.toString() ??
                item['photo']?.toString() ??
                '';
            final role = item['role']?.toString() ?? item['type']?.toString() ?? item['category']?.toString() ?? '';
            final city = item['city']?.toString().trim() ?? '';
            final state = item['state']?.toString().trim() ?? '';
            final loc = item['location']?.toString().trim() ?? '';

            String formatted = loc;
            if (formatted.isEmpty) {
              if (city.isNotEmpty && state.isNotEmpty) {
                formatted = '$city, $state';
              } else if (city.isNotEmpty) {
                formatted = city;
              } else if (state.isNotEmpty) {
                formatted = state;
              }
            }

            if (formatted.isNotEmpty) {
              if (id != null && id.isNotEmpty) {
                locationMap[id] = formatted;
              }
              if (name != null && name.trim().isNotEmpty) {
                locationMap[name.trim().toLowerCase()] = formatted;
              }
            }

            if (id != null && id.isNotEmpty) {
              if (name != null && name.trim().isNotEmpty) {
                nameToIdMap[name.trim().toLowerCase()] = id;
              }
              idToUser[id] = {
                'name': name ?? '',
                'pic': pic,
                'role': role,
              };
            }
          }
        }
      }
    } catch (_) {}
    return {
      'locations': locationMap,
      'nameToId': nameToIdMap,
      'idToUser': idToUser,
    };
  }

  @override
  Future<List<FeedPostModel>> getFeedPosts() async {
    final results = await Future.wait([
      getPhotos(),
      getVideos(),
      _fetchUserLocations(),
    ]);

    final photos = results[0] as List<PhotoModel>;
    final videos = results[1] as List<VideoModel>;
    final userMeta = results[2] as Map<String, dynamic>;
    final userLocations = (userMeta['locations'] as Map<String, String>?) ?? {};
    final nameToId = (userMeta['nameToId'] as Map<String, String>?) ?? {};
    final idToUser = (userMeta['idToUser'] as Map<String, Map<String, String>>?) ?? {};

    final List<FeedPostModel> rawFeed = [
      ...photos.map(FeedPostModel.fromPhotoModel),
      ...videos.map(FeedPostModel.fromVideoModel),
    ];

    // Deduplicate by unique ID and mediaUrl
    final Set<String> seenIds = {};
    final Set<String> seenUrls = {};
    final List<FeedPostModel> uniqueFeed = [];

    for (var post in rawFeed) {
      final hasId = post.id.isNotEmpty;
      final hasUrl = post.mediaUrl.isNotEmpty;

      if (hasId && seenIds.contains(post.id)) {
        continue; // Skip duplicate ID
      }
      if (hasUrl && seenUrls.contains(post.mediaUrl)) {
        continue; // Skip duplicate URL
      }

      // If creatorId is missing, resolve it from nameToId
      if (post.creatorId == null || post.creatorId!.isEmpty) {
        final id = nameToId[post.creatorName.toLowerCase().trim()];
        if (id != null && id.isNotEmpty) {
          post = post.copyWith(creatorId: id);
        }
      }

      // Enrich creatorName / creatorPic / creatorCategory from user directory
      final cId = post.creatorId;
      if (cId != null && cId.isNotEmpty) {
        final userInfo = idToUser[cId];
        if (userInfo != null) {
          final resolvedName = userInfo['name'] ?? '';
          final resolvedPic = userInfo['pic'] ?? '';
          final resolvedRole = userInfo['role'] ?? '';
          // Only overwrite if currently empty / generic fallback
          final needsName = post.creatorName.isEmpty ||
              post.creatorName == 'Creator' ||
              post.creatorName == 'Actor';
          final needsPic = post.creatorPic == null || post.creatorPic!.isEmpty;
          final needsRole = post.creatorCategory == null ||
              post.creatorCategory!.isEmpty ||
              post.creatorCategory == 'Artist' ||
              post.creatorCategory == 'Actor';
          if ((needsName && resolvedName.isNotEmpty) ||
              (needsPic && resolvedPic.isNotEmpty) ||
              (needsRole && resolvedRole.isNotEmpty)) {
            post = post.copyWith(
              creatorName: needsName && resolvedName.isNotEmpty
                  ? resolvedName
                  : null,
              creatorPic: needsPic && resolvedPic.isNotEmpty ? resolvedPic : null,
              creatorCategory: needsRole && resolvedRole.isNotEmpty ? resolvedRole : null,
            );
          }
        }
      }

      // Enrich location dynamically from creator profile if not on post object
      if (post.location.isEmpty) {
        String? loc;
        if (post.creatorId != null && post.creatorId!.isNotEmpty) {
          loc = userLocations[post.creatorId!];
        }
        if (loc == null || loc.isEmpty) {
          loc = userLocations[post.creatorName.toLowerCase().trim()];
        }
        if (loc != null && loc.isNotEmpty) {
          post = post.copyWith(location: loc);
        }
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
  Future<int> getCommentsCount(String videoId) async {
    try {
      final response = await _dioClient.get(ApiEndpoints.videoComments(videoId));
      dynamic listData;
      if (response.data is List) {
        listData = response.data;
      } else if (response.data is Map && (response.data as Map).containsKey('data')) {
        listData = (response.data as Map)['data'];
      } else if (response.data is Map && (response.data as Map).containsKey('comments')) {
        listData = (response.data as Map)['comments'];
      }
      return listData is List ? listData.length : 0;
    } catch (_) {
      return 0;
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
