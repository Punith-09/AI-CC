import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../data/models/audition_model.dart';
import 'audition_card.dart';

class AuditionCards extends StatelessWidget {
  final List<AuditionModel>? auditions;

  const AuditionCards({
    super.key,
    this.auditions,
  });

  @override
  Widget build(BuildContext context) {
    final list = auditions ?? [];

    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            "No auditions found.",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final audition = list[index];
        return AuditionCard(
          audition: audition,
          onView: () => context.push(AppRoutes.auditionDetails, extra: audition),
          onApply: () => context.push(AppRoutes.applyJob, extra: audition),
        );
      },
    );
  }
}