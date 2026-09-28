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
    final columns = isDesktop ? 3 : 2;

    return GridView.builder(
      padding: EdgeInsets.only(bottom: isDesktop ? 40 : 90, top: 4),
      physics: const BouncingScrollPhysics(),
      itemCount: talents.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: isDesktop ? 0.82 : 0.88,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (_, index) {
        return TalentCard(
          talent: talents[index],
        );
      },
    );
  }
}