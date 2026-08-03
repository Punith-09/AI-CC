import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const InfoCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(

        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(.55),

          borderRadius: BorderRadius.circular(22),

          border: Border.all(
            color: AppColors.border.withOpacity(.6),
          ),

          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(.08),
              blurRadius: 18,
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              width: 42,
              height: 42,

              decoration: BoxDecoration(
                color: iconColor.withOpacity(.15),
                shape: BoxShape.circle,
              ),

              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              title,
              style: const TextStyle(
                color: AppColors.greyText,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}