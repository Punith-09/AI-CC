import 'package:aicc/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/artist_model.dart';
import '../../data/models/portfolio_model.dart';
import 'portfolio_card.dart';

class PortfolioGrid extends StatelessWidget {
  final List<PortfolioModel> items;
  final ArtistModel? profile;

  const PortfolioGrid({
    super.key,
    required this.items,
    this.profile,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF103E48).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 40,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            const Text(
              "No posts yet",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Photos and videos you upload will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: .82,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return PortfolioCard(
          item: item,
          onTap: () {
            final post = item.toFeedPostModel(artist: profile);
            context.push(AppRoutes.watchVideo, extra: post);
          },
        );
      },
    );
  }
}