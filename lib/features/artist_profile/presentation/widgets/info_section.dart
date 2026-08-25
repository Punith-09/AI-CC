import 'package:flutter/material.dart';
import 'info_card.dart';

class InfoSection extends StatelessWidget {
  final String? experience;
  final String? languages;

  const InfoSection({super.key, this.experience, this.languages});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InfoCard(
          icon: Icons.workspace_premium_outlined,
          iconColor: const Color(0xff9B51E0),
          title: "Experience",
          value: experience?.isNotEmpty == true ? experience! : "Not specified",
        ),
        const SizedBox(width: 16),
        InfoCard(
          icon: Icons.language,
          iconColor: const Color(0xff2D9CDB),
          title: "Languages",
          value: languages?.isNotEmpty == true ? languages! : "Not specified",
        ),
      ],
    );
  }
}