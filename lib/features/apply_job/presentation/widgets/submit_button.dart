import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class SubmitButton extends StatelessWidget {
  const SubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,

      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),

          gradient: const LinearGradient(
            colors: AppColors.BtnGradient
          ),

          boxShadow: [
            BoxShadow(
              color: Color(0xff20D5FF),
              blurRadius: 18,
              spreadRadius: -4,
            ),
          ],
        ),

        child: ElevatedButton(
          onPressed: () {},

          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),

          child: const Text(
            "Submit Application",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}