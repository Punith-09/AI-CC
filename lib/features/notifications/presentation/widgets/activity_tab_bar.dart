import 'package:flutter/material.dart';

class ActivityTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const ActivityTabBar({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const tabs = ["All", "Matches", "Updates"];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: const Color(0xFF0B1F2A),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: List.generate(
            tabs.length,
                (index) => Expanded(
              child: GestureDetector(
                onTap: () => onChanged(index),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: selectedIndex == index
                        ? const Color(0xffc5bfbf)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      tabs[index],
                      style: TextStyle(
                        color: selectedIndex == index
                            ? Colors.black
                            : Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
