import 'package:flutter/material.dart';

import '../../../../common/widgets/category_chip.dart';
import '../../data/datasource/category_data.dart';

class CategoryChips extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const CategoryChips({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          final category = categories[index];

          return CategoryChip(
            title: category.title,
            icon: category.icon,
            isSelected: selectedIndex == index,
            onTap: () => onSelected(index),
          );
        },
      ),
    );
  }
}