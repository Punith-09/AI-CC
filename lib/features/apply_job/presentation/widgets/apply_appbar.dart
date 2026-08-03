import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';

class ApplyAppBar extends StatelessWidget {
  const ApplyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => context.go("/auditionDetails"),
          child: Row(
            children: const [

              Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.greyText,
                size: 20,
              ),

              SizedBox(width: 30),

            ],
          ),
        ),

        const Spacer(),

        const Text(
          "Submit Application",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const Spacer(),

        const SizedBox(width: 60),
      ],
    );
  }
}