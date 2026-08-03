// import 'package:flutter/material.dart';
//
// class DetailCard extends StatelessWidget {
//   final Widget child;
//
//   const DetailCard({
//     super.key,
//     required this.child,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.92),
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(
//           color: Colors.white.withOpacity(0.2),
//         ),
//       ),
//
//       child: child,
//     );
//   }
// }

import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class DetailCard extends StatelessWidget {
  final Widget child;

  const DetailCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: child,
    );
  }
}