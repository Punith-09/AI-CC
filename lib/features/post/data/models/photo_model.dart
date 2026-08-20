class PhotoModel {
  final String id;
  final String? category;
  final String? creatorId;
  final String? creatorName;
  final String? creatorPic;
  final String? creatorCategory;
  final String title;
  final String? desc;
  final String url;
  final String? thumb;
  final int likesCount;
  final int viewsCount;
  final bool liked;
  final String? createdAt;

  PhotoModel({
    required this.id,
    this.category,
    this.creatorId,
    this.creatorName,
    this.creatorPic,
    this.creatorCategory,
    required this.title,
    this.desc,
    required this.url,
    this.thumb,
    this.likesCount = 0,
    this.viewsCount = 0,
    this.liked = false,
    this.createdAt,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['id'] as String? ?? '',
      category: json['category'] as String?,
      creatorId: json['creatorId'] as String?,
      creatorName: json['creatorName'] as String?,
      creatorPic: json['creatorPic'] as String?,
      creatorCategory: json['creatorCategory'] as String?,
      title: json['title'] as String? ?? '',
      desc: (json['desc'] ?? json['description']) as String?,
      url: json['url'] as String? ?? '',
      thumb: json['thumb'] as String?,
      likesCount: json['likesCount'] as int? ?? 0,
      viewsCount: json['viewsCount'] as int? ?? 0,
      liked: json['liked'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'creatorPic': creatorPic,
      'creatorCategory': creatorCategory,
      'title': title,
      'desc': desc,
      'url': url,
      'thumb': thumb,
      'likesCount': likesCount,
      'viewsCount': viewsCount,
      'liked': liked,
      'createdAt': createdAt,
    };
  }
}
