import 'package:aicc/core/responsive/responsive_breakpoints.dart';
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
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);

    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: BoxDecoration(
          color: isDesktop ? Colors.white : const Color(0xFF103E48).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDesktop ? const Color(0xFFE2E8F0) : Colors.white.withValues(alpha: 0.08),
          ),
          boxShadow: isDesktop
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 40,
              color: isDesktop ? const Color(0xFF94A3B8) : Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              "No posts yet",
              style: TextStyle(
                color: isDesktop ? const Color(0xFF0F172A) : Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Photos and videos you upload will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDesktop ? const Color(0xFF64748B) : Colors.white.withValues(alpha: 0.45),
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
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isDesktop ? 0.88 : 0.82,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return PortfolioCard(
          item: item,
          onTap: () {
            final post = item.toFeedPostModel(artist: profile);
            final enrichedPost = post.copyWith(
              creatorId: (post.creatorId != null && post.creatorId!.isNotEmpty)
                  ? post.creatorId
                  : profile?.id,
              creatorName: post.creatorName.isNotEmpty && post.creatorName != 'Creator'
                  ? post.creatorName
                  : (profile?.name.isNotEmpty == true ? profile!.name : 'Creator'),
              creatorPic: (post.creatorPic != null && post.creatorPic!.isNotEmpty)
                  ? post.creatorPic
                  : profile?.profileImage,
              creatorCategory: post.creatorCategory ?? (profile?.roles.isNotEmpty == true ? profile!.roles.first : 'Artist'),
            );
            context.push(AppRoutes.watchVideo, extra: enrichedPost);
          },
        );
      },
    );
  }
}