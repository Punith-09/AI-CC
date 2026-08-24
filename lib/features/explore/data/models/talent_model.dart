import 'package:flutter/foundation.dart';

@immutable
class TalentModel {
  final String id;
  final String name;
  final String category;
  final String bio;
  final String pic;
  final String handle;
  final int followers;
  final int videosCount;
  final bool following;

  const TalentModel({
    this.id = '',
    this.name = '',
    this.category = '',
    this.bio = '',
    this.pic = '',
    this.handle = '',
    this.followers = 0,
    this.videosCount = 0,
    this.following = false,
  });

  factory TalentModel.fromJson(Map<String, dynamic> json) {
    String parseString(dynamic v) => v == null ? '' : v.toString();
    int parseInt(dynamic v) {
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return TalentModel(
      id: parseString(json['id'] ?? json['_id']),
      name: parseString(json['name'] ?? json['fullName']),
      category: parseString(json['category'] ?? json['role']),
      bio: parseString(json['bio']),
      pic: parseString(json['pic'] ?? json['profilePhoto'] ?? json['image']),
      handle: parseString(json['handle']),
      followers: parseInt(json['followers']),
      videosCount: parseInt(json['videosCount']),
      following: json['following'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'bio': bio,
        'pic': pic,
        'handle': handle,
        'followers': followers,
        'videosCount': videosCount,
        'following': following,
      };
}
