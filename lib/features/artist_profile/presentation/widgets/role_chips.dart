import 'package:flutter/material.dart';

import 'role_chip.dart';

class RoleChips extends StatelessWidget {
  const RoleChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: const [

        RoleChip(
          title: "Actor",
          color: Color(0xff8A2BE2),
        ),

        RoleChip(
          title: "Model",
          color: Color(0xff2F80ED),
        ),

        RoleChip(
          title: "Content Creator",
          color: Color(0xffD63384),
        ),

        RoleChip(
          title: "Voice Artist",
          color: Color(0xff00C2A8),
        ),

        RoleChip(
          title: "Dance Artist",
          color: Color(0xffE0A106),
        ),

        RoleChip(
          title: "Influencer",
          color: Color(0xffFF4FA3),
        ),
      ],
    );
  }
}