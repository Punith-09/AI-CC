import 'package:flutter/material.dart';

import 'package:aicc/core/constants/app_colors.dart';

class GradientCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const GradientCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),

      onTap: () {
        onChanged(!value);
      },

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(
              milliseconds: 200,
            ),

            width: 24,
            height: 24,

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),

              gradient: value
                  ? const LinearGradient(
                colors: [
                  Color(0xff20D5FF),
                  Color(0xffCC3EFF),
                ],
              )
                  : null,

              color: value ? null : AppColors.card,

              border: Border.all(
                color: value
                    ? Colors.transparent
                    : AppColors.border,
              ),
            ),

            child: value
                ? const Icon(
              Icons.check,
              size: 16,
              color: Colors.white,
            )
                : null,
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Text(
              "I authorize this casting house to view my profiles and verify my professional portfolios.",
              style: TextStyle(
                color: AppColors.greyText,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}