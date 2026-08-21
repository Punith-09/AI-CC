import 'package:flutter/material.dart';

import 'package:aicc/core/constants/app_colors.dart';

class GradientTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController? controller;

  const GradientTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        // ------------------------------------------------------
        // LABEL
        // ------------------------------------------------------

        Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  const LinearGradient(
                    colors: [
                      Color(0xff20D5FF),
                      Color(0xffCC3EFF),
                    ],
                  ).createShader(bounds),

              child: Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child: Text(
                label,

                style:
                const TextStyle(
                  fontSize: 18,
                  fontWeight:
                  FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 14,
        ),

        // ------------------------------------------------------
        // TEXT FIELD
        // ------------------------------------------------------

        Container(
          decoration:
          BoxDecoration(
            borderRadius:
            BorderRadius.circular(15),

            gradient:
            const LinearGradient(
              colors: [
                Color(0xff20D5FF),
                Color(0xffCC3EFF),
              ],
            ),
          ),

          padding:
          const EdgeInsets.all(1),

          child: Container(
            decoration:
            BoxDecoration(
              color: AppColors.white,

              borderRadius:
              BorderRadius.circular(15),
            ),

            child: TextField(
              controller:
              controller,

              style:
              const TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),

              cursorColor:
              AppColors.primary,

              decoration:
              InputDecoration(
                border:
                InputBorder.none,

                fillColor:
                AppColors.background,

                contentPadding:
                const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),

                hintText:
                hint,

                hintStyle:
                const TextStyle(
                  color:
                  AppColors.hint,

                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}