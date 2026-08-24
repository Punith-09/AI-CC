import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double radius;
  final double? fontSize;
  final Color? backgroundColor;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 20,
    this.fontSize,
    this.backgroundColor,
  });

  /// Check if the image URL is empty, invalid, or a known generic/placeholder URL.
  static bool isGenericPlaceholder(String? url) {
    if (url == null || url.trim().isEmpty) return true;
    final lower = url.toLowerCase().trim();
    if (!lower.startsWith('http://') && !lower.startsWith('https://')) {
      return true;
    }
    return lower.contains('unsplash.com') ||
        lower.contains('randomuser.me') ||
        lower.contains('placeholder.com') ||
        lower.contains('gravatar.com') ||
        lower.contains('via.placeholder') ||
        lower.contains('picsum.photos') ||
        lower.contains('default') ||
        lower.contains('avatar_default') ||
        lower.endsWith('/default.png') ||
        lower.endsWith('/default.jpg') ||
        lower.endsWith('/default.jpeg');
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? AppColors.primary.withValues(alpha: 0.25);
    final cleanName = name?.trim() ?? '';
    final initial = cleanName.isNotEmpty ? cleanName[0].toUpperCase() : '?';

    Widget buildInitials() {
      return Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          color: effectiveBg,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: fontSize ?? (radius * 0.8),
          ),
        ),
      );
    }

    final cleanUrl = imageUrl?.trim();
    if (isGenericPlaceholder(cleanUrl)) {
      return buildInitials();
    }

    return ClipOval(
      child: Container(
        width: radius * 2,
        height: radius * 2,
        color: effectiveBg,
        child: Image.network(
          cleanUrl!,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => buildInitials(),
        ),
      ),
    );
  }
}
