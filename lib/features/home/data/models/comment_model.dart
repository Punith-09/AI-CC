class CommentModel {
  final String profileImage;
  final String username;
  final String comment;
  final String time;
  int likes;
  final bool isVerified;
  bool isLiked;

  CommentModel({
    required this.profileImage,
    required this.username,
    required this.comment,
    required this.time,
    required this.likes,
    this.isVerified = false,
    this.isLiked = false,
  });
}
