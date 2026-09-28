import 'package:aicc/core/responsive/responsive_breakpoints.dart';
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
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    const tabs = ["All", "Matches", "Updates"];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: isDesktop ? Colors.white : const Color(0xFF0B1F2A),
          borderRadius: BorderRadius.circular(14),
          border: isDesktop ? Border.all(color: const Color(0xFFE2E8F0)) : null,
          boxShadow: isDesktop
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
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
                        ? (isDesktop ? const Color(0xFF8E3CF7) : const Color(0xffc5bfbf))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      tabs[index],
                      style: TextStyle(
                        color: selectedIndex == index
                            ? (isDesktop ? Colors.white : Colors.black)
                            : (isDesktop ? const Color(0xFF64748B) : Colors.white70),
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
