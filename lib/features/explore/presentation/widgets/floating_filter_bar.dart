import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'filter_chip.dart';

class FloatingFilterBar extends StatelessWidget {
  const FloatingFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return
      Positioned(
          left: 0,
          right: 0,
          bottom: 10,
          child: Container(
            height: 58,
            width: 30,
            margin: const EdgeInsets.symmetric(horizontal: 70),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.border.withOpacity(.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                )
              ],
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                FilterChipWidget(
                  title: "Gender",
                  icon: LucideIcons.users,
                  onTap: () {},
                ),
                SizedBox(width: 10),
                FilterChipWidget(
                  title: "Language",
                  icon: LucideIcons.languages,
                  onTap: () {},
                ),
              ],
            ),
          )
      );

  }
}