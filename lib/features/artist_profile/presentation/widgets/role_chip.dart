import 'package:flutter/material.dart';

class RoleChip extends StatelessWidget {
  final String title;
  final Color color;

  const RoleChip({
    super.key,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            color.withOpacity(.9),
            color.withOpacity(.55),
          ],
        ),
        border: Border.all(
          color: color,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(.25),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}