import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';

class AuditionInfoCard extends StatelessWidget {
  const AuditionInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 6),

      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(.55),

        borderRadius: BorderRadius.circular(24),

        border: Border.all(
          color: AppColors.border.withOpacity(.5),
        ),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Container(
          //   width: 75,
          //   height: 75,
          //
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(20),
          //
          //     gradient: const LinearGradient(
          //       colors: [
          //         Color(0xff20D5FF),
          //         Color(0xffCC3EFF),
          //       ],
          //     ),
          //   ),
          //
          //   padding: const EdgeInsets.all(1.5),
          //
          //   child: Container(
          //     decoration: BoxDecoration(
          //       color: AppColors.background,
          //       borderRadius: BorderRadius.circular(18),
          //     ),
          //
          //     child: const Center(
          //       child: Icon(
          //         LucideIcons.music,
          //         color: Colors.purpleAccent,
          //         size: 35,
          //       ),
          //     ),
          //   ),
          // ),

          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:  [

                Text(
                  "Music Video Backup Dancer",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 12),

                RichText(
                  text: TextSpan(
                    children: [

                      TextSpan(
                        text: "Seeking: ",
                        style: TextStyle(
                          color: Colors.purpleAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      TextSpan(
                        text: "Hip Hop Choreography Crew",
                        style: TextStyle(
                          color: AppColors.greyText,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}