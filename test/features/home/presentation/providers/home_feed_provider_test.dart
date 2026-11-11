import 'package:flutter_test/flutter_test.dart';
import 'package:aicc/features/home/data/models/comment_model.dart';
import 'package:aicc/features/home/data/models/feed_post_model.dart';
import 'package:aicc/features/home/data/repository/home_repository.dart';
import 'package:aicc/features/home/presentation/providers/home_feed_provider.dart';

FeedPostModel createDummyVideo(String id) {
  return FeedPostModel(
    id: id,
    type: FeedMediaType.video,
    title: 'Video $id',
    description: 'Desc $id',
    mediaUrl: 'https://example.com/video_$id.mp4',
    creatorName: 'Creator $id',
    likesCount: 5,
    commentsCount: 2,
    viewsCount: 10,
    liked: false,
  );
}

class FakeHomeRepository implements HomeRepository {
  final List<Map<String, int>> requestedParams = [];
  List<FeedPostModel> Function({required int limit, required int offset})? onGetVideosFeed;
  bool shouldThrow = false;
  String errorMessage = 'Network error';

  @override
  Future<List<FeedPostModel>> getVideosFeed({int limit = 4, int offset = 0}) async {
    requestedParams.add({'limit': limit, 'offset': offset});
    if (shouldThrow) {
      throw Exception(errorMessage);
    }
    if (onGetVideosFeed != null) {
      return onGetVideosFeed!(limit: limit, offset: offset);
    }
    return [];
  }

  @override
  Future<List<FeedPostModel>> getFeed() async => [];

  @override
  Future<FeedPostModel?> getVideoById(String id) async => null;

  @override
  Future<Map<String, dynamic>> toggleLike({required String id, required bool isVideo}) async {
    return {'liked': true, 'likesCount': 6};
  }

  @override
  Future<List<CommentModel>> getComments(String videoId) async => [];

  @override
  Future<int> getCommentsCount(String videoId) async => 2;

  @override
  Future<CommentModel> postComment({required String videoId, required String text}) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> toggleCommentLike(String commentId) async => {};

  @override
  Future<void> incrementVideoView(String videoId) async {}
}

void main() {
  late FakeHomeRepository fakeRepo;
  late HomeFeedProvider provider;

  setUp(() {
    fakeRepo = FakeHomeRepository();
    provider = HomeFeedProvider(fakeRepo);
  });

  group('HomeFeedProvider - Video Pagination', () {
    test('Initial load requests 4 videos at offset 0 and updates state', () async {
      fakeRepo.onGetVideosFeed = ({required int limit, required int offset}) {
        expect(limit, 4);
        expect(offset, 0);
        return [
          createDummyVideo('v1'),
          createDummyVideo('v2'),
          createDummyVideo('v3'),
          createDummyVideo('v4'),
        ];
      };

      expect(provider.videoPosts, isEmpty);
      expect(provider.isVideoLoading, isFalse);
      expect(provider.hasMoreVideos, isTrue);

      await provider.fetchVideos();

      expect(provider.videoPosts.length, 4);
      expect(provider.videoPosts.map((v) => v.id).toList(), ['v1', 'v2', 'v3', 'v4']);
      expect(provider.isVideoLoading, isFalse);
      expect(provider.hasMoreVideos, isTrue);
      expect(provider.videoOffset, 4);
      expect(provider.videoErrorMessage, isNull);
      expect(fakeRepo.requestedParams.length, 1);
      expect(fakeRepo.requestedParams.first, {'limit': 4, 'offset': 0});
    });

    test('Swipe-triggered next page requests offset 4, 8 and appends items', () async {
      // First page
      fakeRepo.onGetVideosFeed = ({required int limit, required int offset}) {
        if (offset == 0) {
          return [
            createDummyVideo('v1'),
            createDummyVideo('v2'),
            createDummyVideo('v3'),
            createDummyVideo('v4'),
          ];
        } else if (offset == 4) {
          return [
            createDummyVideo('v5'),
            createDummyVideo('v6'),
            createDummyVideo('v7'),
            createDummyVideo('v8'),
          ];
        } else if (offset == 8) {
          return [
            createDummyVideo('v9'),
            createDummyVideo('v10'),
          ];
        }
        return [];
      };

      await provider.fetchVideos();
      expect(provider.videoPosts.length, 4);
      expect(provider.videoOffset, 4);
      expect(provider.hasMoreVideos, isTrue);

      // Next page (offset 4)
      await provider.fetchMoreVideos();
      expect(provider.videoPosts.length, 8);
      expect(provider.videoPosts[7].id, 'v8');
      expect(provider.videoOffset, 8);
      expect(provider.hasMoreVideos, isTrue);

      // Next page (offset 8)
      await provider.fetchMoreVideos();
      expect(provider.videoPosts.length, 10);
      expect(provider.videoOffset, 10);
      // Returned 2 items (< 4 limit), so hasMoreVideos must be false
      expect(provider.hasMoreVideos, isFalse);

      expect(fakeRepo.requestedParams, [
        {'limit': 4, 'offset': 0},
        {'limit': 4, 'offset': 4},
        {'limit': 4, 'offset': 8},
      ]);
    });

    test('Prevents duplicate video IDs when appending results', () async {
      fakeRepo.onGetVideosFeed = ({required int limit, required int offset}) {
        if (offset == 0) {
          return [
            createDummyVideo('v1'),
            createDummyVideo('v2'),
            createDummyVideo('v3'),
            createDummyVideo('v4'),
          ];
        } else {
          // Contains duplicates of v3 and v4 from page 1, plus new v5 and v6
          return [
            createDummyVideo('v3'),
            createDummyVideo('v4'),
            createDummyVideo('v5'),
            createDummyVideo('v6'),
          ];
        }
      };

      await provider.fetchVideos();
      expect(provider.videoPosts.length, 4);

      await provider.fetchMoreVideos();
      // Should only append v5 and v6 without duplicating v3 and v4
      expect(provider.videoPosts.length, 6);
      expect(provider.videoPosts.map((v) => v.id).toList(), ['v1', 'v2', 'v3', 'v4', 'v5', 'v6']);
    });

    test('Stops further requests when a page returns fewer than 4 results', () async {
      fakeRepo.onGetVideosFeed = ({required int limit, required int offset}) {
        return [
          createDummyVideo('v1'),
          createDummyVideo('v2'),
        ];
      };

      await provider.fetchVideos();
      expect(provider.videoPosts.length, 2);
      expect(provider.hasMoreVideos, isFalse);

      // Subsequent fetchMoreVideos call should NOT trigger a request
      await provider.fetchMoreVideos();
      expect(fakeRepo.requestedParams.length, 1);
    });

    test('Handles empty initial feed gracefully', () async {
      fakeRepo.onGetVideosFeed = ({required int limit, required int offset}) => [];

      await provider.fetchVideos();
      expect(provider.videoPosts, isEmpty);
      expect(provider.hasMoreVideos, isFalse);
      expect(provider.isVideoLoading, isFalse);
      expect(provider.videoErrorMessage, isNull);

      await provider.fetchMoreVideos();
      expect(fakeRepo.requestedParams.length, 1);
    });

    test('Refresh resets pagination offset and hasMore state', () async {
      fakeRepo.onGetVideosFeed = ({required int limit, required int offset}) {
        if (offset == 0) {
          return [
            createDummyVideo('v1'),
            createDummyVideo('v2'),
            createDummyVideo('v3'),
            createDummyVideo('v4'),
          ];
        }
        return [createDummyVideo('v5')];
      };

      await provider.fetchVideos();
      await provider.fetchMoreVideos();
      expect(provider.videoPosts.length, 5);
      expect(provider.hasMoreVideos, isFalse);

      // Refresh
      fakeRepo.onGetVideosFeed = ({required int limit, required int offset}) {
        return [
          createDummyVideo('fresh_1'),
          createDummyVideo('fresh_2'),
          createDummyVideo('fresh_3'),
          createDummyVideo('fresh_4'),
        ];
      };

      await provider.fetchVideos(isRefresh: true);
      expect(provider.videoPosts.length, 4);
      expect(provider.videoPosts.first.id, 'fresh_1');
      expect(provider.videoOffset, 4);
      expect(provider.hasMoreVideos, isTrue);
      expect(fakeRepo.requestedParams.last, {'limit': 4, 'offset': 0});
    });

    test('Initial request failure sets errorMessage and retains error state', () async {
      fakeRepo.shouldThrow = true;
      fakeRepo.errorMessage = 'Connection refused';

      await provider.fetchVideos();

      expect(provider.videoPosts, isEmpty);
      expect(provider.isVideoLoading, isFalse);
      expect(provider.videoErrorMessage, 'Connection refused');
    });

    test('Next-page request failure retains existing videos and resets loading flag', () async {
      fakeRepo.onGetVideosFeed = ({required int limit, required int offset}) {
        return [
          createDummyVideo('v1'),
          createDummyVideo('v2'),
          createDummyVideo('v3'),
          createDummyVideo('v4'),
        ];
      };

      await provider.fetchVideos();
      expect(provider.videoPosts.length, 4);

      // Page 2 fails
      fakeRepo.shouldThrow = true;
      await provider.fetchMoreVideos();

      // Existing videos remain visible
      expect(provider.videoPosts.length, 4);
      expect(provider.isLoadingMoreVideos, isFalse);
    });

    test('Toggling like on a paginated video updates liked and likesCount', () async {
      fakeRepo.onGetVideosFeed = ({required int limit, required int offset}) {
        return [createDummyVideo('v1')];
      };

      await provider.fetchVideos();
      expect(provider.videoPosts.first.liked, isFalse);
      expect(provider.videoPosts.first.likesCount, 5);

      await provider.toggleLike('v1');
      expect(provider.videoPosts.first.liked, isTrue);
      expect(provider.videoPosts.first.likesCount, 6);
    });
  });
}
