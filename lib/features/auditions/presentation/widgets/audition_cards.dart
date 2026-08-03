import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'audition_card.dart';

class AuditionCards extends StatelessWidget{
  const AuditionCards({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AuditionCard(
          title: "Music Video Backup Dancer",
          category: "Dancer",
          location: "Bangalore",
          deadline: "2026-11-20",
          payout: "₹15,000 project payout",
          applicants: "N/A",
          description:
          "High energy, urban hip hop backup dancers needed for a prominent music label's latest pop single. Fast pacing learning and coordination ability are required.",
          onView: () {context.go("/auditionDetails");},
          onApply: () {context.go("/applyScreen");},
        ),
        AuditionCard(
          title: "Music Video Backup Dancer",
          category: "Dancer",
          location: "Bangalore",
          deadline: "2026-11-20",
          payout: "₹15,000 project payout",
          applicants: "N/A",
          description:
          "High energy, urban hip hop backup dancers needed for a prominent music label's latest pop single. Fast pacing learning and coordination ability are required.",
          onView: () {context.go("/auditionDetails");},
          onApply: () {context.go("/applyScreen");},
        ),
        AuditionCard(
          title: "Music Video Backup Dancer",
          category: "Dancer",
          location: "Bangalore",
          deadline: "2026-11-20",
          payout: "₹15,000 project payout",
          applicants: "N/A",
          description:
          "High energy, urban hip hop backup dancers needed for a prominent music label's latest pop single. Fast pacing learning and coordination ability are required.",
          onView: () {context.go("/auditionDetails");},
          onApply: () {context.go("/applyScreen");},
        ),
      ],
    );
  }
}