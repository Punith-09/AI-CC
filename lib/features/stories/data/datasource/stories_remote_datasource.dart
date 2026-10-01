import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/story_item_model.dart';
import '../models/user_stories_group_model.dart';

abstract class StoriesRemoteDataSource {
  Future<List<UserStoriesGroupModel>> getStoriesFeed({int limit = 20, int offset = 0});

  Future<StoryItemModel> uploadStory({
    required String fileName,
    String? filePath,
    Uint8List? fileBytes,
  });

  Future<bool> markStoryViewed(String storyId);

  Future<bool> deleteStory(String storyId);
}

class StoriesRemoteDataSourceImpl implements StoriesRemoteDataSource {
  final DioClient _dioClient;

  StoriesRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<UserStoriesGroupModel>> getStoriesFeed({int limit = 20, int offset = 0}) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.storiesFeed,
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      final dynamic data = response.data;
      List<dynamic> rawStories = [];

      if (data is Map) {
        if (data['stories'] is List) {
          rawStories = data['stories'] as List<dynamic>;
        } else if (data['data'] is List) {
          rawStories = data['data'] as List<dynamic>;
        }
      } else if (data is List) {
        rawStories = data;
      }

      return rawStories
          .map((e) => UserStoriesGroupModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Failed to load stories feed',
      );
    } catch (e) {
      throw Exception('Failed to load stories feed: $e');
    }
  }

  @override
  Future<StoryItemModel> uploadStory({
    required String fileName,
    String? filePath,
    Uint8List? fileBytes,
  }) async {
    MultipartFile multipartFile;

    if (fileBytes != null) {
      multipartFile = MultipartFile.fromBytes(
        fileBytes,
        filename: fileName,
      );
    } else if (!kIsWeb && filePath != null) {
      multipartFile = await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      );
    } else {
      throw Exception('No media file provided for story upload.');
    }

    final formData = FormData.fromMap({
      'file': multipartFile,
    });

    try {
      final response = await _dioClient.post(
        ApiEndpoints.stories,
        data: formData,
      );

      if (response.data is Map) {
        return StoryItemModel.fromJson(Map<String, dynamic>.from(response.data as Map));
      } else {
        throw Exception('Invalid server response format for story upload');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Failed to upload story',
      );
    } catch (e) {
      throw Exception('Failed to upload story: $e');
    }
  }

  @override
  Future<bool> markStoryViewed(String storyId) async {
    try {
      final response = await _dioClient.post(ApiEndpoints.storyView(storyId));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteStory(String storyId) async {
    try {
      final response = await _dioClient.delete(ApiEndpoints.deleteStory(storyId));
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Failed to delete story',
      );
    } catch (e) {
      throw Exception('Failed to delete story: $e');
    }
  }
}
