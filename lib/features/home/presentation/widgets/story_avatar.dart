import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class StoryAvatarItem extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final String? assetPath;
  final bool isMine;
  final bool hasStory;
  final bool hasUnviewed;
  final VoidCallback onTap;
  final VoidCallback? onAddTap;

  const StoryAvatarItem({
    super.key,
    required this.name,
    this.imageUrl,
    this.assetPath,
    this.isMine = false,
    this.hasStory = false,
    this.hasUnviewed = true,
    required this.onTap,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return SizedBox(
      width: 76,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                child: Container(
                  width: 68,
                  height: 68,
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: (hasStory && hasUnviewed)
                        ? const LinearGradient(
                            colors: [
                              Color(0xFFFF9500),
                              Color(0xFFFF5E00),
                              Color(0xFFFFB800),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    border: (hasStory && hasUnviewed)
                        ? null
                        : Border.all(
                            color: hasStory
                                ? (isDark ? Colors.white38 : Colors.black26)
                                : (isDark ? Colors.white24 : Colors.black12),
                            width: 1.5,
                          ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? const Color(0xFF0D0D0D) : Colors.white,
                    ),
                    child: ClipOval(
                      child: _buildAvatarImage(isDark),
                    ),
                  ),
                ),
              ),

              // Orange "+" badge for "Your Story"
              if (isMine)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onAddTap ?? onTap,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8A00),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? Colors.black : Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF8A00).withValues(alpha: 0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: isMine ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage(bool isDark) {
    if (imageUrl != null && imageUrl!.trim().isNotEmpty && imageUrl!.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: isDark ? Colors.white10 : Colors.black12,
          child: const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.primary),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildFallback(isDark),
      );
    }

    if (assetPath != null && assetPath!.trim().isNotEmpty) {
      return Image.asset(
        assetPath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(isDark),
      );
    }

    return _buildFallback(isDark);
  }

  Widget _buildFallback(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF222222) : const Color(0xFFEEEEEE),
      child: Center(
        child: isMine
            ? Icon(
                Icons.person_rounded,
                color: isDark ? Colors.white60 : Colors.black45,
                size: 32,
              )
            : Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
      ),
    );
  }
}