import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// import 'category_model.dart';

const categories = [

  ExploreCategory(
    title: "",
    icon: LucideIcons.slidersHorizontal,
  ),

  ExploreCategory(
    title: "All",
  ),

  ExploreCategory(
    title: "Actor",
  ),

  ExploreCategory(
    title: "Model",
  ),

  ExploreCategory(
    title: "Singer",
  ),
];



class ExploreCategory {
  final String title;
  final IconData? icon;

  const ExploreCategory({
    required this.title,
    this.icon,
  });
}
