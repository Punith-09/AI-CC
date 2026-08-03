import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class GradientCheckbox extends StatefulWidget {
  const GradientCheckbox({super.key});

  @override
  State<GradientCheckbox> createState() => _GradientCheckboxState();
}

class _GradientCheckboxState extends State<GradientCheckbox> {
  bool checked = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        setState(() {
          checked = !checked;
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 24,
            height: 24,

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),

              gradient: checked
                  ? const LinearGradient(
                colors: [
                  Color(0xff20D5FF),
                  Color(0xffCC3EFF),
                ],
              )
                  : null,

              color: checked ? null : AppColors.card,

              border: Border.all(
                color: checked
                    ? Colors.transparent
                    : AppColors.border,
              ),
            ),

            child: checked
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