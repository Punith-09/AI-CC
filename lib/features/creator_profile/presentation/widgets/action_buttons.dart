import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Row(
        children: [

          Expanded(
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),

                gradient: const LinearGradient(
                  colors: [
                    Color(0xff20D5FF),
                    Color(0xffCC3EFF),
                  ],
                ),
              ),

              child: ElevatedButton(
                onPressed: () {},

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),

                child: const Text(
                  "Follow",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: OutlinedButton(
              onPressed: () {},

              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(54),

                side: const BorderSide(
                  color: AppColors.primary,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),

              child: const Text(
                "Message",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}