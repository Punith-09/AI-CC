import 'dart:typed_data';

import '../datasource/stories_remote_datasource.dart';
import '../models/story_item_model.dart';
import '../models/user_stories_group_model.dart';

abstract class StoriesRepository {
  Future<List<UserStoriesGroupModel>> getStoriesFeed({int limit = 20, int offset = 0});

  Future<StoryItemModel> uploadStory({
    required String fileName,
    String? filePath,
    Uint8List? fileBytes,
  });

  Future<bool> markStoryViewed(String storyId);

  Future<bool> deleteStory(String storyId);
}

class StoriesRepositoryImpl implements StoriesRepository {
  final StoriesRemoteDataSource remoteDataSource;

  StoriesRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<UserStoriesGroupModel>> getStoriesFeed({int limit = 20, int offset = 0}) {
    return remoteDataSource.getStoriesFeed(limit: limit, offset: offset);
  }

  @override
  Future<StoryItemModel> uploadStory({
    required String fileName,
    String? filePath,
    Uint8List? fileBytes,
  }) {
    return remoteDataSource.uploadStory(
      fileName: fileName,
      filePath: filePath,
      fileBytes: fileBytes,
    );
  }

  @override
  Future<bool> markStoryViewed(String storyId) {
    return remoteDataSource.markStoryViewed(storyId);
  }

  @override
  Future<bool> deleteStory(String storyId) {
    return remoteDataSource.deleteStory(storyId);
  }
}
