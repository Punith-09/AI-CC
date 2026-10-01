import 'package:aicc/features/explore/data/models/talent_model.dart';
import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive_breakpoints.dart';
import 'talent_card.dart';

class TalentGrid extends StatelessWidget {
  final List<TalentModel> talents;

  const TalentGrid({
    super.key,
    required this.talents,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);

    // On desktop keep a 2-column grid; on mobile use a vertical list
    if (isDesktop) {
      return GridView.builder(
        padding: const EdgeInsets.only(bottom: 40, top: 4),
        physics: const BouncingScrollPhysics(),
        itemCount: talents.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 0,
        ),
        itemBuilder: (_, index) => TalentCard(talent: talents[index]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 90, top: 4),
      physics: const BouncingScrollPhysics(),
      itemCount: talents.length,
      itemBuilder: (_, index) => TalentCard(talent: talents[index]),
    );
  }
}