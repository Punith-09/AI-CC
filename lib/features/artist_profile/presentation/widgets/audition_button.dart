// import 'package:aicc/core/constants/app_colors.dart';
// import 'package:flutter/material.dart';
//
// class AuditionButton extends StatelessWidget {
//   const AuditionButton({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       height: 58,
//       child: ElevatedButton.icon(
//         onPressed: () {},
//         icon: const Icon(
//           Icons.mic,
//           color: Colors.white,
//         ),
//
//         label: const Text(
//           "Contact For Audition",
//           style: TextStyle(
//             fontSize: 17,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//
//         style: ElevatedButton.styleFrom(
//
//           foregroundColor: Colors.white,
//           backgroundColor: AppColors.primary,
//           elevation: 0,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(18),
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AuditionButton extends StatelessWidget {
  const AuditionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.secondary, // Change to your preferred end color
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(
            Icons.mic,
            color: Colors.white,
          ),
          label: const Text(
            "Contact For Audition",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
    );
  }
}