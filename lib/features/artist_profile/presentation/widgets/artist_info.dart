import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ArtistInfo extends StatelessWidget {
  const ArtistInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          children: [

            const Text(
              "Isha Sharma",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(width: 8),

            Icon(
              Icons.verified,
              color: AppColors.primary,
              size: 28,
            )
          ],
        ),

        const SizedBox(height: 8),

        Row(
          children: [

            Icon(
              Icons.location_on_outlined,
              size: 20,
              color: AppColors.greyText,
            ),

            const SizedBox(width: 6),

            const Text(
              "Mumbai, Maharashtra",
              style: TextStyle(
                color: AppColors.greyText,
                fontSize: 18,
              ),
            )
          ],
        ),
      ],
    );
  }
}