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
      padding: const EdgeInsets.only(bottom: 90, top: 4),
      physics: const BouncingScrollPhysics(),
      itemCount: talents.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.88,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemBuilder: (_, index) {
        return TalentCard(
          talent: talents[index],
        );
      },
    );
  }
}