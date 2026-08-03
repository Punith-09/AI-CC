import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class CreatorInfo extends StatelessWidget {
  const CreatorInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        const Text(
          "Ariana Kapoor",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          "@arianakapoor",
          style: TextStyle(
            color: AppColors.greyText,
            fontSize: 18,
          ),
        ),

        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Text(
            "Film Director",
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ),

        const SizedBox(height: 18),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              Icons.location_on_outlined,
              size: 18,
              color: AppColors.greyText,
            ),

            const SizedBox(width: 6),

            const Text(
              "Mumbai, India",
              style: TextStyle(
                color: AppColors.greyText,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            "Award-winning filmmaker passionate about discovering fresh talent and creating meaningful cinema.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.greyText,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}