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
    if (city != null &&
        city!.isNotEmpty &&
        state != null &&
        state!.isNotEmpty) {
      location = '$city, $state';
    } else if (city != null && city!.isNotEmpty) {
      location = city!;
    } else if (state != null && state!.isNotEmpty) {
      location = state!;
    } else {
      location = 'Location not available';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              name?.isNotEmpty == true ? name! : "",
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 20,
              color: AppColors.greyText,
            ),
            const SizedBox(width: 6),
            Text(
              location,
              style: const TextStyle(color: AppColors.greyText, fontSize: 18),
            ),
          ],
        ),
      ],
    );
  }
}
