import 'package:flutter/material.dart';

import 'social_button.dart';

class SocialLinks extends StatelessWidget {
  const SocialLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [

        SocialButton(
          icon: Icons.camera_alt_outlined,
          label: "Instagram",
          color: Color(0xffE1306C),
        ),

        SizedBox(width: 14),

        SocialButton(
          icon: Icons.facebook_outlined,
          label: "Facebook",
          color: Color(0xff1877F2),
        ),

        SizedBox(width: 14),

        SocialButton(
          icon: Icons.mail_outline,
          label: "Email",
          color: Color(0xff00D4FF),
        ),
      ],
    );
  }
}