import 'package:aicc/core/api/api_endpoints.dart';
import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

import '../../data/models/portfolio_model.dart';

class PortfolioCard extends StatelessWidget {
  final PortfolioModel item;
  final VoidCallback? onTap;

  const PortfolioCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cleanUrl = ApiEndpoints.formatMediaUrl(item.image);
    final isNetwork = cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://');
    final isAsset = cleanUrl.startsWith('assets/');

    Widget buildPlaceholder() {
      return Container(
        color: const Color(0xFF103E48),
        alignment: Alignment.center,
        child: Icon(
          item.isVideo ? Icons.videocam_outlined : Icons.photo_outlined,
          color: Colors.white38,
          size: 32,
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (isNetwork)
              Image.network(
                cleanUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => buildPlaceholder(),
              )
            else if (isAsset)
              Image.asset(
                cleanUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => buildPlaceholder(),
              )
            else
              buildPlaceholder(),

            if (item.isVideo)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),

            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}