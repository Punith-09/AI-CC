import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:aicc/core/constants/app_colors.dart';

import '../../../../core/routes/app_routes.dart';
import '../../data/models/audition_model.dart';

class BottomActionBar extends StatelessWidget {
  final AuditionModel? audition;
  final VoidCallback? onApply;

  const BottomActionBar({
    super.key,
    this.audition,
    this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () {

                      context.go(AppRoutes.auditions);

                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFF06233E),
                    side: const BorderSide(
                      color: Color(0xFF1CC8FF),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Not Interested",
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        size: 18,
                        color: AppColors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  gradient:  LinearGradient(
                    colors: AppColors.BtnGradient,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ElevatedButton(
                  onPressed: onApply ??
                      () {
                        context.push(AppRoutes.applyJob, extra: audition);
                      },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "APPLY NOW",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}