class StoryModel {
  final String image;
  final String name;
  final bool isLive;
  final bool isMine;

  StoryModel({
    required this.image,
    required this.name,
    this.isLive = false,
    this.isMine = false,
  });
}