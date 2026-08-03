import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ExploreSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final bool readOnly;

  const ExploreSearchBar({
    super.key,
    this.controller,
    this.onTap,
    this.onChanged,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(colors: [
          AppColors.primary,
          AppColors.secondary,
          AppColors.gradient
        ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.card.withOpacity(.1),
        ),
      ),
      child: TextField(

        controller: controller,

        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 17,

        ),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          border: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
          ),

          prefixIcon: Padding(
            padding: const EdgeInsets.only(
              left: 18,
              right: 12,
            ),
            child: Icon(
              LucideIcons.search,
              color: AppColors.hint,
              size: 24,
            ),
          ),

          prefixIconConstraints: const BoxConstraints(
            minWidth: 55,
          ),

          hintText: "Search by name, role or skills...",

          hintStyle: TextStyle(
            color: AppColors.hint,
            fontSize: 17,
          ),
        ),
      ),
    );
  }
}