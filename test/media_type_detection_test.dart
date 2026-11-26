import 'package:flutter_test/flutter_test.dart';
import 'package:aicc/core/api/api_endpoints.dart';
import 'package:aicc/features/home/data/models/feed_post_model.dart';
import 'package:aicc/features/post/data/models/video_model.dart';
import 'package:aicc/features/post/data/models/photo_model.dart';

void main() {
  group('Media type detection tests', () {
    test('Photo post returned by videos endpoint is correctly treated as photo', () {
      final photoInVideoEndpoint = VideoModel(
        id: '912e3b88-f145-438d-90db-d621cb41b629',
        category: 'Photos',
        creatorId: '78060ab2-9603-4b57-a4ed-91e0cf4c503d',
        creatorName: 'Jane Doe',
        creatorPic: 'https://cloudinary.com/avatar.jpg',
        creatorCategory: 'Actor',
        title: 'string2',
        desc: 'string2',
        url: 'https://res.cloudinary.com/prmynfbv/image/upload/v1788952746/photos/smljbutifgcjcxeys7nu.jpg',
        thumb: 'https://res.cloudinary.com/prmynfbv/image/upload/v1788952746/photos/smljbutifgcjcxeys7nu.jpg',
      );

      final feedPost = FeedPostModel.fromVideoModel(photoInVideoEndpoint);

      expect(feedPost.isVideo, isFalse);
      expect(feedPost.isPhoto, isTrue);
      expect(feedPost.type, equals(FeedMediaType.photo));
      expect(feedPost.hashtags, contains('#Portfolio'));
      expect(feedPost.hashtags, isNot(contains('#Reel')));
    });

    test('Real video post is correctly treated as video', () {
      final realVideo = VideoModel(
        id: 'real-video-123',
        category: 'Acting',
        creatorName: 'Jane Doe',
        title: 'Monologue',
        url: 'https://res.cloudinary.com/prmynfbv/video/upload/v1788952746/videos/audition.mp4',
      );

      final feedPost = FeedPostModel.fromVideoModel(realVideo);

      expect(feedPost.isVideo, isTrue);
      expect(feedPost.isPhoto, isFalse);
      expect(feedPost.type, equals(FeedMediaType.video));
      expect(feedPost.hashtags, contains('#Reel'));
    });

    test('PhotoModel with video URL is correctly detected as video', () {
      final videoInPhotoModel = PhotoModel(
        id: 'photo-video-123',
        category: 'Reels',
        title: 'Short clip',
        url: 'https://example.com/clip.mov',
      );

      final feedPost = FeedPostModel.fromPhotoModel(videoInPhotoModel);

      expect(feedPost.isVideo, isTrue);
      expect(feedPost.isPhoto, isFalse);
    });

    test('PhotoModel with image URL is correctly detected as photo', () {
      final photo = PhotoModel(
        id: 'photo-123',
        category: 'Headshot',
        title: 'Portrait',
        url: 'https://example.com/image.png',
      );

      final feedPost = FeedPostModel.fromPhotoModel(photo);

      expect(feedPost.isVideo, isFalse);
      expect(feedPost.isPhoto, isTrue);
    });

    test('isVideoMediaUrl detects various file types accurately', () {
      // Images
      expect(FeedPostModel.isVideoMediaUrl('https://site.com/pic.jpg'), isFalse);
      expect(FeedPostModel.isVideoMediaUrl('https://site.com/pic.jpeg?w=100'), isFalse);
      expect(FeedPostModel.isVideoMediaUrl('https://site.com/pic.png#anchor'), isFalse);
      expect(FeedPostModel.isVideoMediaUrl('https://site.com/pic.webp'), isFalse);
      expect(FeedPostModel.isVideoMediaUrl('https://site.com/pic.gif'), isFalse);
      expect(FeedPostModel.isVideoMediaUrl('assets/images/post1.jpeg'), isFalse);

      // Videos
      expect(FeedPostModel.isVideoMediaUrl('https://site.com/vid.mp4'), isTrue);
      expect(FeedPostModel.isVideoMediaUrl('https://site.com/vid.mov?token=123'), isTrue);
      expect(FeedPostModel.isVideoMediaUrl('https://site.com/vid.webm'), isTrue);
      expect(FeedPostModel.isVideoMediaUrl('https://site.com/vid.mkv'), isTrue);
      expect(FeedPostModel.isVideoMediaUrl('https://site.com/vid.avi'), isTrue);
      expect(FeedPostModel.isVideoMediaUrl('assets/videos/sample.mp4'), isTrue);
      expect(FeedPostModel.isVideoMediaUrl('https://res.cloudinary.com/demo/video/upload/sample'), isTrue);
    });

    test('getVideoStartingFrameUrl extracts poster image accurately', () {
      // Cloudinary video URLs
      expect(
        ApiEndpoints.getVideoStartingFrameUrl('https://res.cloudinary.com/demo/video/upload/sample.mp4'),
        equals('https://res.cloudinary.com/demo/video/upload/so_0,w_720,c_limit,q_auto/sample.jpg'),
      );
      expect(
        ApiEndpoints.getVideoStartingFrameUrl('https://res.cloudinary.com/demo/video/upload/v123456/sample.mp4'),
        equals('https://res.cloudinary.com/demo/video/upload/so_0,w_720,c_limit,q_auto/v123456/sample.jpg'),
      );
      expect(
        ApiEndpoints.getVideoStartingFrameUrl('https://res.cloudinary.com/demo/video/upload/q_auto,w_720,c_limit,f_mp4/v123456/sample.mp4'),
        equals('https://res.cloudinary.com/demo/video/upload/so_0,w_720,c_limit,q_auto/v123456/sample.jpg'),
      );
      // Non-Cloudinary returns null
      expect(ApiEndpoints.getVideoStartingFrameUrl('https://example.com/video.mp4'), isNull);
      expect(ApiEndpoints.getVideoStartingFrameUrl(''), isNull);
    });

    test('isDefaultClapperboardOrPlaceholder correctly detects placeholder and clapperboard URLs', () {
      expect(ApiEndpoints.isDefaultClapperboardOrPlaceholder(null), isTrue);
      expect(ApiEndpoints.isDefaultClapperboardOrPlaceholder(''), isTrue);
      expect(ApiEndpoints.isDefaultClapperboardOrPlaceholder('https://images.unsplash.com/photo-1594909122845-11baa439b7bf?auto=format&fit=crop&w=800&q=80'), isTrue);
      expect(ApiEndpoints.isDefaultClapperboardOrPlaceholder('https://example.com/clapperboard.png'), isTrue);
      expect(ApiEndpoints.isDefaultClapperboardOrPlaceholder('https://res.cloudinary.com/demo/image/upload/custom_cover.jpg'), isFalse);
    });
  });
}
