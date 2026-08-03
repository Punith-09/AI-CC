import 'package:flutter/material.dart';

import 'info_card.dart';

class InfoSection extends StatelessWidget {
  const InfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [

        InfoCard(
          icon: Icons.workspace_premium_outlined,
          iconColor: Color(0xff9B51E0),
          title: "Experience",
          value: "6+ Years",
        ),

        SizedBox(width: 16),

        InfoCard(
          icon: Icons.language,
          iconColor: Color(0xff2D9CDB),
          title: "Languages",
          value: "Hindi   English\nTelugu",
        ),
      ],
    );
  }
}