import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class UploadFileCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? fileName;
  final VoidCallback onTap;

  const UploadFileCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.fileName,
  });

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
                Icons.upload_file_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Container(
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [
                Color(0xff20D5FF),
                Color(0xffCC3EFF),
              ],
            ),
          ),

          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(17),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.greyText,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 18),

                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primary
                      )
                    ),

                    child: Row(
                      children: [

                        const Icon(
                          Icons.attach_file,
                          color: AppColors.primary,
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            fileName ?? "Choose File",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: fileName == null
                                  ? AppColors.greyText
                                  : Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),

                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppColors.greyText,
                        ),
                      ],
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