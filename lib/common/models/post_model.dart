class PostModel {
  final String profileImage;
  final String userName;
  final String location;
  final bool isVerified;
  final String postImage;
  final String caption;
  final String hashtags;
  final String likes;
  final String time;

  const PostModel({
    required this.profileImage,
    required this.userName,
    required this.location,
    required this.isVerified,
    required this.postImage,
    required this.caption,
    required this.hashtags,
    required this.likes,
    required this.time,
  });
}