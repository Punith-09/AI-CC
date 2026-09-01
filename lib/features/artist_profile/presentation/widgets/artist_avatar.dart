import 'package:aicc/core/api/api_endpoints.dart';
import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ArtistAvatar extends StatelessWidget {
  final String? profileImage;
  final String? name;
  const ArtistAvatar({super.key, this.profileImage, this.name});

  @override
  Widget build(BuildContext context) {
    final cleanUrl = profileImage != null ? ApiEndpoints.formatMediaUrl(profileImage!) : '';
    final isNetwork = cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://');
    final isAsset = cleanUrl.startsWith('assets/');

    final cleanName = name?.trim() ?? '';
    final initial = cleanName.isNotEmpty ? cleanName[0].toUpperCase() : 'A';

    Widget buildFallback() {
      return Container(
        color: const Color(0xFF103E48),
        alignment: Alignment.center,
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 42,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

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
                color: AppColors.primary.withValues(alpha: .35),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: isNetwork
                ? Image.network(
                    cleanUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => buildFallback(),
                  )
                : (isAsset
                    ? Image.asset(
                        cleanUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => buildFallback(),
                      )
                    : buildFallback()),
          ),
        ),

        // Positioned(
        //   bottom: 6,
        //   right: 4,
        //   child: Container(
        //     width: 28,
        //     height: 28,
        //     decoration: BoxDecoration(
        //       color: Colors.green,
        //       shape: BoxShape.circle,
        //       border: Border.all(
        //         color: AppColors.background,
        //         width: 3,
        //       ),
        //     ),
        //     child: const Icon(
        //       Icons.check,
        //       size: 16,
        //       color: Colors.white,
        //     ),
        //   ),
        // ),
      ],
    );
  }
}