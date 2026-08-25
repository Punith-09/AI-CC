import 'package:aicc/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

class CreateBottomSheet extends StatelessWidget {
  const CreateBottomSheet({super.key});

  static const Color backgroundColor = Color(0xFF082F38);
  static const Color cardColor = Color(0xFF103E48);
  static const Color accentColor = Color(0xFF25C7F2);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 Text(
                   "Create",
                   style: GoogleFonts.montserrat(
                     color: AppColors.white,
                     fontSize: 22,
                     // letterSpacing: 2.1,
                     fontWeight: FontWeight.w800,
                   ),
                 )
                ],
              ),

              const SizedBox(height: 22),

              // Post Audition
              _CreateOption(
                icon: Icons.assignment_outlined,
                title: 'Post Audition',
                subtitle: 'Create a casting call',
                onTap: () => Navigator.pop(context, AppRoutes.post),
              ),

              const SizedBox(height: 10),

              // Upload Video
              _CreateOption(
                icon: Icons.video_library_outlined,
                title: 'Upload Video',
                subtitle: 'Share your portfolio reel',
                onTap: () => Navigator.pop(context, AppRoutes.uploadVideo),
              ),

              const SizedBox(height: 10),

              // Upload Photo
              _CreateOption(
                icon: Icons.photo_camera_outlined,
                title: 'Upload Photo',
                subtitle: 'Add to your portfolio',
                onTap: () => Navigator.pop(context, AppRoutes.uploadPhoto),
              ),

              const SizedBox(height: 18),

              // Divider
              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.08),
              ),

              const SizedBox(height: 8),

              // Cancel
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CreateOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF103E48),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF25C7F2).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF25C7F2),
                  size: 24,
                ),
              ),

              const SizedBox(width: 14),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white30,
                size: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}