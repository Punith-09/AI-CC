import 'package:flutter/material.dart';

import 'package:aicc/core/constants/app_colors.dart';

class CoverLetterField extends StatefulWidget {
  final TextEditingController controller;

  const CoverLetterField({
    super.key,
    required this.controller,
  });

  @override
  State<CoverLetterField> createState() =>
      _CoverLetterFieldState();
}

class _CoverLetterFieldState
    extends State<CoverLetterField> {
  @override
  void initState() {
    super.initState();

    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final length = widget.controller.text.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              child: const Icon(
                Icons.edit_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),

            const SizedBox(width: 10),

            const Expanded(
              child: Text(
                "Cover Letter (Minimum 20 characters)",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [
                Color(0xff20D5FF),
                Color(0xffCC3EFF),
              ],
            ),
          ),
          padding: const EdgeInsets.all(1),

          child: Container(
            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(17),
            ),

            child: Column(
              children: [
                TextField(
                  controller: widget.controller,

                  maxLines: 7,
                  minLines: 7,

                  style: const TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                  ),

                  cursorColor: AppColors.primary,

                  decoration: const InputDecoration(
                    border: InputBorder.none,

                    hintText:
                    "Pitch why you are the perfect candidate for this role...",

                    hintStyle: TextStyle(
                      color: AppColors.hint,
                      fontSize: 17,
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    "$length / 20",
                    style: TextStyle(
                      color: length >= 20
                          ? Colors.green
                          : Colors.redAccent,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}