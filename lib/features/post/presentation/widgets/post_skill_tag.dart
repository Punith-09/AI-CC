import 'package:flutter/material.dart';
class PostSkillTag extends StatelessWidget {
  final String title;
  final bool selected;

  const PostSkillTag({
    required this.title,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: selected
            ? Colors.deepPurple.withValues(alpha: 0.15)
            : const Color(0xff2A2A33),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: selected ? Colors.deepPurpleAccent : Colors.grey.shade700,
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: selected ? Colors.deepPurpleAccent : Colors.white70,
          fontSize: 14,
        ),
      ),
    );
  }
}
