class PhotoModel {
  final String id;
  final String? category;
  final String? creatorId;
  final String? creatorName;
  final String? creatorPic;
  final String? creatorCategory;
  final String? location;
  final String? city;
  final String? state;
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
    this.location,
    this.city,
    this.state,
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
    final creatorMap = json['creator'] is Map
        ? json['creator'] as Map<String, dynamic>
        : (json['user'] is Map ? json['user'] as Map<String, dynamic> : null);

    return PhotoModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      category: json['category'] as String?,
      creatorId: json['creatorId'] as String? ?? json['userId'] as String?,
      creatorName: json['creatorName'] as String? ?? creatorMap?['fullName'] as String? ?? creatorMap?['name'] as String?,
      creatorPic: json['creatorPic'] as String? ?? creatorMap?['profilePhoto'] as String? ?? creatorMap?['avatar'] as String?,
      creatorCategory: json['creatorCategory'] as String? ?? creatorMap?['role'] as String? ?? creatorMap?['category'] as String?,
      location: json['location'] as String? ?? creatorMap?['location'] as String?,
      city: json['city'] as String? ?? json['creatorCity'] as String? ?? creatorMap?['city'] as String?,
      state: json['state'] as String? ?? json['creatorState'] as String? ?? creatorMap?['state'] as String?,
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
