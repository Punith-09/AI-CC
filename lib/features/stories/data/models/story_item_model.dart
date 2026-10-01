class StoryItemModel {
  final String id;
  final String mediaUrl;
  final String mediaType; // "image" or "video"
  final DateTime? createdAt;
  final DateTime? expiresAt;
  final bool viewed;

  const StoryItemModel({
    required this.id,
    required this.mediaUrl,
    required this.mediaType,
    this.createdAt,
    this.expiresAt,
    this.viewed = false,
  });

  bool get isVideo => mediaType.toLowerCase() == 'video';

  factory StoryItemModel.fromJson(Map<String, dynamic> json) {
    return StoryItemModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      mediaUrl: json['mediaUrl']?.toString() ?? json['url']?.toString() ?? '',
      mediaType: json['mediaType']?.toString() ?? 'image',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())
          : null,
      viewed: json['viewed'] == true,
    );
  }

  StoryItemModel copyWith({
    String? id,
    String? mediaUrl,
    String? mediaType,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? viewed,
  }) {
    return StoryItemModel(
      id: id ?? this.id,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      viewed: viewed ?? this.viewed,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'mediaUrl': mediaUrl,
    'mediaType': mediaType,
    'createdAt': createdAt?.toIso8601String(),
    'expiresAt': expiresAt?.toIso8601String(),
    'viewed': viewed,
  };
}
