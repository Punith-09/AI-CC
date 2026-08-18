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

  static final List<AuditionModel> _defaultAuditions = [
    const AuditionModel(
      id: "1",
      title: "Music Video Backup Dancer",
      category: "Dancer",
      role: "Backup Crew",
      language: "N/A",
      pay: "₹15,000 project payout",
      location: "Bangalore",
      deadline: "2026-11-20",
      description:
          "High energy, urban hip hop backup dancers needed for a prominent music label's latest pop single. Fast pacing learning and coordination ability are required.",
      director: "Pulse Studios",
      phone: "+91 98765 43210",
      email: "producer@email.com",
    ),
    const AuditionModel(
      id: "2",
      title: "Music Video Backup Dancer",
      category: "Hero(18-28)",
      role: "Backup Crew",
      language: "N/A",
      pay: "₹15,000 project payout",
      location: "Bangalore",
      deadline: "2026-11-20",
      description:
          "High energy, urban hip hop backup dancers needed for a prominent music label's latest pop single. Fast pacing learning and coordination ability are required.",
      director: "Pulse Studios",
      phone: "+91 98765 43210",
      email: "producer@email.com",
    ),
    const AuditionModel(
      id: "3",
      title: "Music Video Backup Dancer",
      category: "Dancer",
      role: "Backup Crew",
      language: "N/A",
      pay: "₹15,000 project payout",
      location: "Bangalore",
      deadline: "2026-11-20",
      description:
          "High energy, urban hip hop backup dancers needed for a prominent music label's latest pop single. Fast pacing learning and coordination ability are required.",
      director: "Pulse Studios",
      phone: "+91 98765 43210",
      email: "producer@email.com",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final list = auditions ?? _defaultAuditions;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final audition = list[index];
        return AuditionCard(
          audition: audition,
          onView: () => context.go(AppRoutes.auditionDetails),
          onApply: () => context.go(AppRoutes.applyJob),
        );
      },
    );
  }
}