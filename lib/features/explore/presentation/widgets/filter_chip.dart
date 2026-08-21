import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class FilterChipWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const FilterChipWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(

          padding: const EdgeInsets.symmetric(vertical:5,horizontal: 0 ),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(30)
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Icon(
                  icon,
                  size: 16,
                  color: AppColors.white,
                ),

                const SizedBox(width: 8),

                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}