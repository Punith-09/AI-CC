import 'package:flutter/material.dart';

@immutable
class ActivityModel {
  final String id;
  final String title;
  final String subtitle;
  final String time;
  final String badge;
  final Color badgeColor;
  final bool highlight;

  const ActivityModel({
    this.id = '',
    required this.title,
    required this.subtitle,
    required this.time,
    required this.badge,
    required this.badgeColor,
    this.highlight = false,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      time: json['time'] as String? ?? '',
      badge: json['badge'] as String? ?? '',
      badgeColor: Color(json['badge_color'] as int? ?? 0xFF4AD0FB),
      highlight: json['highlight'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'time': time,
        'badge': badge,
        'badge_color': badgeColor.toARGB32(),
        'highlight': highlight,
      };
}
