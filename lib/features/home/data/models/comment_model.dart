import 'package:flutter/foundation.dart';
import '../../../../core/storage/local_storage.dart';

@immutable
class CommentModel {
  final String id;
  final String userId;
  final String profileImage;
  final String username;
  final String comment;
  final String time;
  final int likes;
  final bool isVerified;
  final bool isLiked;
  final String? createdAt;

  const CommentModel({
    this.id = '',
    this.userId = '',
    required this.profileImage,
    required this.username,
    required this.comment,
    required this.time,
    required this.likes,
    this.isVerified = false,
    this.isLiked = false,
    this.createdAt,
  });

  String get timeAgo => formatInstagramTime(createdAt ?? time);

  static String formatInstagramTime(String? rawDate) {
    if (rawDate == null || rawDate.trim().isEmpty) {
      return '1m';
    }
    try {
      final String cleanDate = rawDate.trim();
      final DateTime parsed = DateTime.parse(cleanDate);
      final DateTime now = DateTime.now();

      // The PostgreSQL DB timestamp without timezone stores the local time directly (e.g. 11:14:07).
      // If the backend appends 'Z', parsing it as UTC creates a false ~5.5h future discrepancy against local time.
      // Therefore we calculate the time difference in local timeline:
      DateTime createdLocal = DateTime(
        parsed.year,
        parsed.month,
        parsed.day,
        parsed.hour,
        parsed.minute,
        parsed.second,
      );

      Duration diff = now.difference(createdLocal);

      // If diff is negative (e.g. if the date was strictly UTC), try standard UTC difference:
      if (diff.isNegative) {
        final Duration diffUtc = now.toUtc().difference(parsed.toUtc());
        if (!diffUtc.isNegative) {
          diff = diffUtc;
        } else {
          diff = Duration.zero;
        }
      }

      if (diff.inMinutes < 1) {
        return '1m';
      }
      if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m';
      }
      if (diff.inHours < 24) {
        return '${diff.inHours}h';
      }
      if (diff.inDays < 7) {
        return '${diff.inDays}d';
      }
      if (diff.inDays < 30) {
        final weeks = (diff.inDays / 7).floor();
        return '${weeks}w';
      }
      if (diff.inDays < 365) {
        final months = (diff.inDays / 30).floor();
        return '${months}mo';
      }
      final years = (diff.inDays / 365).floor();
      return '${years}y';
    } catch (_) {
      if (rawDate.toLowerCase().contains('now')) {
        return '1m';
      }
      return rawDate;
    }
  }

  CommentModel copyWith({
    String? id,
    String? userId,
    String? profileImage,
    String? username,
    String? comment,
    String? time,
    int? likes,
    bool? isVerified,
    bool? isLiked,
    String? createdAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      profileImage: profileImage ?? this.profileImage,
      username: username ?? this.username,
      comment: comment ?? this.comment,
      time: time ?? this.time,
      likes: likes ?? this.likes,
      isVerified: isVerified ?? this.isVerified,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    String userId = '';
    String username = '';
    String profileImage = '';

    // 1. Inspect nested user/author/creator/profile/postedBy object if present
    Map<String, dynamic>? userMap;
    if (json['user'] is Map) {
      userMap = Map<String, dynamic>.from(json['user'] as Map);
    } else if (json['userId'] is Map) {
      userMap = Map<String, dynamic>.from(json['userId'] as Map);
    } else if (json['author'] is Map) {
      userMap = Map<String, dynamic>.from(json['author'] as Map);
    } else if (json['creator'] is Map) {
      userMap = Map<String, dynamic>.from(json['creator'] as Map);
    } else if (json['profile'] is Map) {
      userMap = Map<String, dynamic>.from(json['profile'] as Map);
    } else if (json['postedBy'] is Map) {
      userMap = Map<String, dynamic>.from(json['postedBy'] as Map);
    }

    if (userMap != null) {
      userId = (userMap['_id'] ?? userMap['id'] ?? '').toString();

      final nameVal = userMap['fullName'] ??
          userMap['name'] ??
          userMap['username'] ??
          userMap['userName'] ??
          userMap['displayName'];
      if (nameVal != null && nameVal.toString().trim().isNotEmpty) {
        username = nameVal.toString().trim();
      }

      final picVal = userMap['profilePhoto'] ??
          userMap['profile_photo'] ??
          userMap['profilePic'] ??
          userMap['profile_pic'] ??
          userMap['avatar'] ??
          userMap['profileImage'] ??
          userMap['profile_image'] ??
          userMap['photoUrl'] ??
          userMap['image'];
      if (picVal != null && picVal.toString().trim().isNotEmpty) {
        profileImage = picVal.toString().trim();
      }
    }

    // 2. Direct top-level fields
    if (userId.isEmpty) {
      if (json['userId'] is String) {
        userId = json['userId'].toString();
      } else if (json['creatorId'] != null) {
        userId = json['creatorId'].toString();
      } else if (json['authorId'] != null) {
        userId = json['authorId'].toString();
      }
    }

    if (username.isEmpty) {
      // Backend returns string "author": "Artist1" or "fullName": "..."
      if (json['author'] is String && (json['author'] as String).isNotEmpty) {
        username = (json['author'] as String).trim();
      } else {
        final topName = json['fullName'] ??
            json['userFullName'] ??
            json['authorName'] ??
            json['creatorName'] ??
            json['userName'] ??
            json['username'] ??
            json['name'] ??
            json['displayName'];
        if (topName != null && topName.toString().trim().isNotEmpty) {
          username = topName.toString().trim();
        }
      }
    }

    if (profileImage.isEmpty) {
      final topImage = json['authorPic'] ??
          json['userPic'] ??
          json['profilePhoto'] ??
          json['profile_photo'] ??
          json['profilePic'] ??
          json['profile_pic'] ??
          json['avatar'] ??
          json['profile_image'] ??
          json['profileImage'] ??
          json['photoUrl'] ??
          json['image'];
      if (topImage != null && topImage.toString().trim().isNotEmpty) {
        profileImage = topImage.toString().trim();
      }
    }

    // 3. If this comment is from the CURRENT logged-in user and name was missing from JSON
    if (username.isEmpty && userId.isNotEmpty) {
      try {
        final currentLoggedInId = LocalStorage.instance.getUserId();
        if (currentLoggedInId != null &&
            currentLoggedInId.isNotEmpty &&
            currentLoggedInId == userId) {
          username = LocalStorage.instance.getUserName() ?? 'You';
          if (profileImage.isEmpty) {
            profileImage = LocalStorage.instance.getUserProfilePhoto() ?? '';
          }
        }
      } catch (_) {}
    }

    if (username.isEmpty) {
      username = 'Artist';
    }

    final commentText =
        (json['text'] ?? json['comment'] ?? json['content'] ?? '').toString();

    // Instagram style formatted time
    final rawCreated = (json['createdAt'] ?? json['created_at'] ?? json['createdAtUtc'])?.toString();
    final formattedTime = formatInstagramTime(rawCreated ?? json['time']?.toString());

    final rawLikes = json['likesCount'] ?? json['likes'] ?? 0;
    final int likesCount =
        rawLikes is int ? rawLikes : int.tryParse(rawLikes.toString()) ?? 0;

    final rawLiked =
        json['liked'] ?? json['isLiked'] ?? json['is_liked'] ?? false;
    final bool liked =
        rawLiked is bool ? rawLiked : rawLiked.toString() == 'true';

    return CommentModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      userId: userId,
      profileImage: profileImage,
      username: username,
      comment: commentText,
      time: formattedTime,
      likes: likesCount,
      isVerified: json['is_verified'] as bool? ?? false,
      isLiked: liked,
      createdAt: rawCreated,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'profile_image': profileImage,
        'username': username,
        'comment': comment,
        'time': time,
        'likes': likes,
        'is_verified': isVerified,
        'is_liked': isLiked,
        if (createdAt != null) 'createdAt': createdAt,
      };
}
