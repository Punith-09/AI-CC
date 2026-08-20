import 'package:flutter/material.dart';

import 'role_chip.dart';

class RoleChips extends StatelessWidget {
  final List<String>? roles;

  const RoleChips({super.key, this.roles});

  @override
  Widget build(BuildContext context) {
    final displayRoles = (roles != null && roles!.isNotEmpty)
        ? roles!
        : ["Actor", "Model", "Content Creator", "Voice Artist", "Dance Artist", "Influencer"];

    final colors = [
      const Color(0xff8A2BE2),
      const Color(0xff2F80ED),
      const Color(0xffD63384),
      const Color(0xff00C2A8),
      const Color(0xffE0A106),
      const Color(0xffFF4FA3),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(displayRoles.length, (index) {
        return RoleChip(
          title: displayRoles[index],
          color: colors[index % colors.length],
        );
      }),
    );
  }
}