import 'package:flutter/material.dart';

class SkillChip extends StatelessWidget {
  final String skill;
  final bool selected;
  final VoidCallback? onTap;

  const SkillChip({
    super.key,
    required this.skill,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF123B4A).withOpacity(0.15)
              : const Color(0xff2C2C35),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: selected
                ? const Color(0xFF123B4A)
                : Colors.white10,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.check_circle,
                  color: Color(0xFF123B4A),
                  size: 16,
                ),
              ),
            Text(
              skill,
              style: TextStyle(
                color: selected
                    ? Colors.white70
                    : Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}