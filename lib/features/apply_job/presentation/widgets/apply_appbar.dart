import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';

class ApplyAppBar extends StatelessWidget {
  final VoidCallback? onDelete;
  final String title;

  const ApplyAppBar({
    super.key,
    this.onDelete,
    this.title = 'Submit Application',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // =====================================================
        // BACK
        // =====================================================

        InkWell(
          borderRadius:
          BorderRadius.circular(30),

          onTap: () {
            context.pop();
          },

          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.greyText,
              size: 20,
            ),
          ),
        ),

        // =====================================================
        // TITLE
        // =====================================================

        Expanded(
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // =====================================================
        // ACTIONS
        // =====================================================

        if (onDelete != null)
          _ActionIconButton(
            icon: Icons.delete_outline_rounded,
            gradient: const [
              Color(0xffEB5757),
              Color(0xffFF8C42),
            ],
            onTap: onDelete!,
          )
        else
          const SizedBox(width: 44),
      ],
    );
  }
}

class _ActionIconButton
    extends StatelessWidget {
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _ActionIconButton({
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
        BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient:
            LinearGradient(
              colors: gradient,
            ),
            borderRadius:
            BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: gradient.last
                    .withValues(alpha: 0.35),
                blurRadius: 10,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}