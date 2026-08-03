import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class CoverLetterField extends StatefulWidget {
  const CoverLetterField({super.key});

  @override
  State<CoverLetterField> createState() => _CoverLetterFieldState();
}

class _CoverLetterFieldState extends State<CoverLetterField> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          children: [

            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
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

            const Text(
              "Cover Letter (Minimum 20 characters)",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
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
                  controller: controller,
                  maxLines: 7,
                  minLines: 7,

                  style: const TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                  ),

                  cursorColor: AppColors.primary,

                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    fillColor: AppColors.background,
                    hintText:
                    "Pitch why you are the perfect candidate for this role...",

                    hintStyle: TextStyle(
                      color: AppColors.hint,
                      fontSize: 17,
                    ),
                  ),

                  onChanged: (_) {
                    setState(() {});
                  },
                ),

                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    "${controller.text.length} / 20",
                    style: TextStyle(
                      color: controller.text.length >= 20
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