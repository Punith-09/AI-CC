import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const SocialButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.card.withOpacity(.55),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.border.withOpacity(.6),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(.15),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 28,
              ),

              const SizedBox(height: 10),

              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}