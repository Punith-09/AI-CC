// import 'package:flutter/material.dart';
//
// import '../../data/category_data.dart';
// import 'category_chip.dart';
//
// class CategoryChips extends StatefulWidget {
//   const CategoryChips({super.key});
//
//   @override
//   State<CategoryChips> createState() => _CategoryChipsState();
// }
//
// class _CategoryChipsState extends State<CategoryChips> {
//   int selectedIndex = 1;
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 54,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemCount: categories.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 12),
//         itemBuilder: (_, index) {
//           final category = categories[index];
//
//           return CategoryChip(
//             title: category.title,
//             icon: category.icon,
//             isSelected: selectedIndex == index,
//             onTap: () {
//               setState(() {
//                 selectedIndex = index;
//               });
//             },
//           );
//         },
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

import '../../data/datasource/category_data.dart';
import 'category_chip.dart';

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
        separatorBuilder: (_, __) => const SizedBox(width: 12),
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