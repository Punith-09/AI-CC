import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class FooterDecoration extends StatelessWidget {
  const FooterDecoration();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 96,
          height: 1,
          color: const Color(0x183D7080),
        ),

        const SizedBox(width: 12),

        Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            color: const Color(0x081D8CA8),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: const Color(0xFF2A7E98),
              width: 1.2,
            ),
          ),
          child: const Icon(
            LucideIcons.shieldCheck,
            color: Color(0xFF3A9AB6),
            size: 17,
          ),
        ),

        const SizedBox(width: 12),

        Container(
          width: 96,
          height: 1,
          color: const Color(0x183D7080),
        ),
      ],
    );
  }
}
