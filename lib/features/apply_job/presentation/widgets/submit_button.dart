import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  /// Button label – defaults to "Submit Application".
  final String label;

  const SubmitButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.label = "Submit Application",
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,

      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),

          gradient: const LinearGradient(
            colors: AppColors.BtnGradient,
          ),

          boxShadow: const [
            BoxShadow(
              color: Color(0xff20D5FF),
              blurRadius: 18,
              spreadRadius: -4,
            ),
          ],
        ),

        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,

          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),

          child: isLoading
              ? const SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.white,
            ),
          )
              : Text(
            label,
            style: const TextStyle(
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