import 'package:flutter/foundation.dart';

import '../../../../core/storage/local_storage.dart';
import '../../data/models/story_item_model.dart';
import '../../data/models/user_stories_group_model.dart';
import '../../data/repository/stories_repository.dart';

class StoriesProvider extends ChangeNotifier {
  final StoriesRepository _repository;

  StoriesProvider(this._repository);

  List<UserStoriesGroupModel> _storyGroups = [];
  bool _isLoading = false;
  bool _isUploading = false;
  String? _errorMessage;

  List<UserStoriesGroupModel> get storyGroups => _storyGroups;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;

  String? get currentUserId {
    try {
      return LocalStorage.instance.getUserId();
    } catch (_) {
      return null;
    }
  }

  /// The logged-in user's active story group (if any)
  UserStoriesGroupModel? get myStoriesGroup {
    final myId = currentUserId;
    if (myId == null || myId.isEmpty) return null;
    try {
      return _storyGroups.firstWhere(
        (group) => group.creatorId == myId,
      );
    } catch (_) {
      return null;
    }
  }

  /// All other users' stories
  List<UserStoriesGroupModel> get otherStoriesGroups {
    final myId = currentUserId;
    if (myId == null || myId.isEmpty) return _storyGroups;
    return _storyGroups.where((group) => group.creatorId != myId).toList();
  }

  bool get hasMyStory => myStoriesGroup != null && myStoriesGroup!.items.isNotEmpty;

  Future<void> fetchStories({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final groups = await _repository.getStoriesFeed(limit: 50, offset: 0);
      _storyGroups = groups;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<StoryItemModel> uploadStory({
    required String fileName,
    String? filePath,
    Uint8List? fileBytes,
  }) async {
    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final story = await _repository.uploadStory(
        fileName: fileName,
        filePath: filePath,
        fileBytes: fileBytes,
      );

      // Refresh stories feed to get updated grouped list
      await fetchStories(silent: true);

      _isUploading = false;
      notifyListeners();
      return story;
    } catch (e) {
      _isUploading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> markStoryViewed(String storyId, String creatorId) async {
    // 1. Optimistic local update
    final groupIndex = _storyGroups.indexWhere((g) => g.creatorId == creatorId);
    if (groupIndex != -1) {
      final group = _storyGroups[groupIndex];
      final itemIndex = group.items.indexWhere((item) => item.id == storyId);
      if (itemIndex != -1) {
        final updatedItems = List<StoryItemModel>.from(group.items);
        updatedItems[itemIndex] = updatedItems[itemIndex].copyWith(viewed: true);

        final allViewed = updatedItems.every((item) => item.viewed);
        _storyGroups[groupIndex] = group.copyWith(
          items: updatedItems,
          hasUnviewed: !allViewed,
        );
        notifyListeners();
      }
    }

    // 2. Server update
    try {
      await _repository.markStoryViewed(storyId);
    } catch (_) {
      // Ignored
    }
  }

  Future<bool> deleteStory(String storyId, String creatorId) async {
    try {
      final success = await _repository.deleteStory(storyId);
      if (success) {
        final groupIndex = _storyGroups.indexWhere((g) => g.creatorId == creatorId);
        if (groupIndex != -1) {
          final group = _storyGroups[groupIndex];
          final updatedItems = group.items.where((i) => i.id != storyId).toList();
          if (updatedItems.isEmpty) {
            _storyGroups.removeAt(groupIndex);
          } else {
            final allViewed = updatedItems.every((item) => item.viewed);
            _storyGroups[groupIndex] = group.copyWith(
              items: updatedItems,
              hasUnviewed: !allViewed,
            );
          }
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }
}
