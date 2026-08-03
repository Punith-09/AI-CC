import 'package:flutter/material.dart';

import 'package:aicc/core/constants/app_colors.dart';

class AuditionSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  const AuditionSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(

      height: 46,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: "Search role title, location...",
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 22,
            color: Colors.grey,
          ),
          filled: true,
          fillColor: AppColors.card,
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(
              color: AppColors.card.withOpacity(.08),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(
              color: Color(0xff6C63FF),
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}