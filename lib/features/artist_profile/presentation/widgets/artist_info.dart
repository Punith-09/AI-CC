import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ArtistInfo extends StatelessWidget {
  final String? name;
  final String? state;
  final String? city;
  
  const ArtistInfo({super.key, this.name, this.state, this.city});

  @override
  Widget build(BuildContext context) {
    String location = "";
    if (city != null && city!.isNotEmpty && state != null && state!.isNotEmpty) {
      location = '$city, $state';
    } else if (city != null && city!.isNotEmpty) {
      location = city!;
    } else if (state != null && state!.isNotEmpty) {
      location = state!;
    } else {
      location = 'Location not available';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name?.isNotEmpty == true ? name! : "Unknown",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            // const Icon(
            //   Icons.verified,
            //   color: AppColors.primary,
            //   size: 24,
            // ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 18,
              color: AppColors.greyText,
            ),
            const SizedBox(width: 4),
            Text(
              location,
              style: const TextStyle(
                color: AppColors.greyText,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }
}