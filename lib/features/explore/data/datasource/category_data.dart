import 'package:flutter/material.dart';

const categories = [
  ExploreCategory(title: "", icon: Icons.tune_rounded), // index 0 – hidden in new UI
  ExploreCategory(title: "All"),
  ExploreCategory(title: "Actors"),
  ExploreCategory(title: "Models"),
  ExploreCategory(title: "Dancers"),
  ExploreCategory(title: "Singers"),
];

class ExploreCategory {
  final String title;
  final IconData? icon;

  const ExploreCategory({
    required this.title,
    this.icon,
  });
}
