import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class RecommendationGraphic extends StatelessWidget {
  const RecommendationGraphic({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,

      child: Stack(
        alignment: Alignment.center,

        children: [

          Container(
            width: 120,
            height: 120,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              border: Border.all(
                color: Colors.blue.withOpacity(.15),
              ),
            ),
          ),

          Container(
            width: 90,
            height: 90,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              border: Border.all(
                color: Colors.blue.withOpacity(.25),
              ),
            ),
          ),

          Container(
            width: 60,
            height: 60,

            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}