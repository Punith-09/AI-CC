import 'package:aicc/core/api/api_endpoints.dart';
import 'package:aicc/core/constants/app_colors.dart';
import 'package:aicc/core/responsive/responsive_breakpoints.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cleanUrl = ApiEndpoints.formatMediaUrl(item.image);
    final isNetwork = cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://');
    final isAsset = cleanUrl.startsWith('assets/');

    Widget buildPlaceholder() {
      return Container(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
        alignment: Alignment.center,
        child: Icon(
          item.isVideo ? Icons.videocam_outlined : Icons.photo_outlined,
          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
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
                    color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
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