import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:aicc/core/constants/app_colors.dart';

class AuditionSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onTap;

  const AuditionSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onClear,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasText = controller != null && controller!.text.isNotEmpty;
    final textColor = isDark ? Colors.white : AppColors.lightText;
    const hintColor = Color(0xFF7A7A7A);
    const borderColor = Color(0xFF5A4418);
    final fillColor = isDark ? const Color(0xFF0D0D0D) : AppColors.lightTextField;

    return SizedBox(
      height: 44,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
        ),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: "Search by role title, location",
          hintStyle: const TextStyle(
            color: hintColor,
            fontSize: 13.5,
          ),
          prefixIcon: const Icon(
            LucideIcons.search,
            size: 18,
            color: Color(0xFFA37D42),
          ),
          suffixIcon: hasText
              ? IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 16,
                    color: Color(0xFFA37D42),
                  ),
                  onPressed: onClear,
                )
              : null,
          filled: true,
          fillColor: fillColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(
              color: isDark ? borderColor : const Color(0xFFCBD5E1),
              width: 1.1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(
              color: Color(0xFFFF9500),
              width: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}