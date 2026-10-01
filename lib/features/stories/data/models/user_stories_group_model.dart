import 'story_item_model.dart';

class UserStoriesGroupModel {
  final String creatorId;
  final String creatorName;
  final String creatorUsername;
  final String? creatorPic;
  final bool hasUnviewed;
  final List<StoryItemModel> items;

  const UserStoriesGroupModel({
    required this.creatorId,
    required this.creatorName,
    required this.creatorUsername,
    this.creatorPic,
    this.hasUnviewed = false,
    this.items = const [],
  });

  String get displayName {
    if (creatorName.trim().isNotEmpty) {
      return creatorName.trim().split(' ').first;
    }
    if (creatorUsername.trim().isNotEmpty) {
      return creatorUsername.trim();
    }
    return 'Creator';
  }

  factory UserStoriesGroupModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final itemsList = rawItems
        .map((e) => StoryItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return UserStoriesGroupModel(
      creatorId: json['creatorId']?.toString() ?? '',
      creatorName: json['creatorName']?.toString() ?? '',
      creatorUsername: json['creatorUsername']?.toString() ?? '',
      creatorPic: json['creatorPic']?.toString(),
      hasUnviewed: json['hasUnviewed'] == true,
      items: itemsList,
    );
  }

  UserStoriesGroupModel copyWith({
    String? creatorId,
    String? creatorName,
    String? creatorUsername,
    String? creatorPic,
    bool? hasUnviewed,
    List<StoryItemModel>? items,
  }) {
    return UserStoriesGroupModel(
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      creatorUsername: creatorUsername ?? this.creatorUsername,
      creatorPic: creatorPic ?? this.creatorPic,
      hasUnviewed: hasUnviewed ?? this.hasUnviewed,
      items: items ?? this.items,
    );
  }
}
