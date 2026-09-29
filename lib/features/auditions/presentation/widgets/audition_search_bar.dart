import 'package:flutter/material.dart';

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
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final hintColor = isDark ? AppColors.darkTextSecondary : AppColors.hint;
    final iconColor = isDark ? AppColors.darkTextSecondary : AppColors.grey;
    final fillColor = isDark ? AppColors.darkTextField : AppColors.lightTextField;
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);

    return SizedBox(
      height: 46,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        style: TextStyle(
          color: textColor,
          fontSize: 14.5,
        ),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: "Search role title, location...",
          hintStyle: TextStyle(
            color: hintColor,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 22,
            color: iconColor,
          ),
          suffixIcon: hasText
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: iconColor,
                  ),
                  onPressed: onClear,
                )
              : null,
          filled: true,
          fillColor: fillColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}