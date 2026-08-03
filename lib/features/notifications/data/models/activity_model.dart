import 'package:flutter/material.dart';

class ActivityModel {
  final String title;
  final String subtitle;
  final String time;
  final String badge;
  final Color badgeColor;
  final bool highlight;

  const ActivityModel({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.badge,
    required this.badgeColor,
    this.highlight = false,
  });
}
