// import 'package:aicc/features/explore/data/talents_data.dart';
// import 'package:flutter/material.dart';
//
// import 'talent_card.dart';
//
// class TalentGrid extends StatelessWidget {
//   const TalentGrid({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       physics: const BouncingScrollPhysics(),
//
//       itemCount: talents.length,
//
//       gridDelegate:
//       const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//
//         childAspectRatio: .72,
//
//         crossAxisSpacing: 16,
//
//         mainAxisSpacing: 18,
//       ),
//
//       itemBuilder: (_, index) {
//         return TalentCard(
//           talent: talents[index],
//         );
//       },
//     );
//   }
// }



import 'package:aicc/features/explore/data/models/talent_model.dart';
import 'package:flutter/material.dart';

import 'talent_card.dart';

class TalentGrid extends StatelessWidget {
  final List<TalentModel> talents;

  const TalentGrid({
    super.key,
    required this.talents,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 100),

      physics: const BouncingScrollPhysics(),

      itemCount: talents.length,

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: .72,
        crossAxisSpacing: 16,
        mainAxisSpacing: 18,
      ),

      itemBuilder: (_, index) {
        return TalentCard(
          talent: talents[index],
        );
      },
    );
  }
}