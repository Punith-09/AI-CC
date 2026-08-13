import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/social_button.dart';
class SocialButtons extends StatelessWidget {
  final VoidCallback? onGoogleTap;
  final VoidCallback? onAppleTap;
  final VoidCallback? onFacebookTap;

  const SocialButtons({
    super.key,
    this.onGoogleTap,
    this.onAppleTap,
    this.onFacebookTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SocialButton(
          icon: FontAwesomeIcons.google,
          iconColor: Colors.white,
          label: 'Google',
          onTap: onGoogleTap,
        ),

        const SizedBox(width: 15),

        SocialButton(
          icon: FontAwesomeIcons.apple,
          iconColor: Colors.white,
          label: 'Apple',
          onTap: onAppleTap,
        ),

        const SizedBox(width: 15),

        SocialButton(
          icon: FontAwesomeIcons.facebook,
          iconColor: const Color(0xFF1877F2),
          label: 'Facebook',
          onTap: onFacebookTap,
        ),
      ],
    );
  }
}
