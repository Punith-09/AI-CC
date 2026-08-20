import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ArtistAvatar extends StatelessWidget {
  final String? profileImage;
  const ArtistAvatar({super.key, this.profileImage});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(.35),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: (profileImage != null && profileImage!.isNotEmpty && profileImage!.startsWith('http'))
                ? Image.network(
                    profileImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      "assets/images/profile2.jpeg",
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    profileImage != null && profileImage!.isNotEmpty ? profileImage! : "assets/images/profile2.jpeg",
                    fit: BoxFit.cover,
                  ),
          ),
        ),

        Positioned(
          bottom: 6,
          right: 4,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.background,
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.check,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}