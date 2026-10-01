import 'package:flutter/material.dart';

class AuditionChips extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const AuditionChips({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 22),
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelected(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    categories[index],
                    style: TextStyle(
                      color: isSelected
                          ? (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : const Color(0xFF111827))
                          : const Color(0xFF8E8E93),
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                // Amber/Orange underline indicator for active tab
                if (isSelected)
                  Container(
                    width: 32,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9500),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )
                else
                  const SizedBox(height: 2.5),
              ],
            ),
          );
        },
      ),
    );
  }
}