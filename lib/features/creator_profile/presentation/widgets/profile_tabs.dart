import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ProfileTabs extends StatefulWidget {
  const ProfileTabs({super.key});

  @override
  State<ProfileTabs> createState() => _ProfileTabsState();
}

class _ProfileTabsState extends State<ProfileTabs> {

  int selected = 0;

  final tabs = [
    "Posts",
    "Photos",
    "Videos",
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,

      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,

        itemBuilder: (_, index) {

          final isSelected = selected == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selected = index;
              });
            },

            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),

              margin: const EdgeInsets.only(right: 14),

              padding: const EdgeInsets.symmetric(
                horizontal: 22,
              ),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),

                color: isSelected
                    ? AppColors.primary
                    : AppColors.card,
              ),

              alignment: Alignment.center,

              child: Text(
                tabs[index],
                style: TextStyle(
                  color: isSelected
                      ? Colors.black
                      : AppColors.greyText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}