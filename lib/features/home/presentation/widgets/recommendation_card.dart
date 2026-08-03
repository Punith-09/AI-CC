import 'package:aicc/features/home/presentation/widgets/recommendation_graphic.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 165,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),

        gradient: const LinearGradient(
          colors: [
            Color(0xff536b7c),
            Color(0xff081B3D),
          ],
        ),

        border: Border.all(
          color: Colors.white10,
        ),
      ),

      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Row(
          children: [

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "AI Recommendation",
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.auto_awesome,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  const Text(
                    "Based on your search for\n"
                        "\"Young Professional\","
                        " we \nfound 12 new"
                        " matches \nfor you.",

                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 18),
                  //
                  // SizedBox(
                  //   // height: 42,
                  //   width: 150,
                  //   child: ElevatedButton(
                  //     onPressed: () {},
                  //
                  //     child: const Text("View Matches"),
                  //   ),
                  // )
                  SizedBox(
                    width: 150,
                    height: 45,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.secondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "View Matches",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(width: 20),

            const RecommendationGraphic(),

          ],
        ),
      ),
    );
  }
}