import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String? coverImage;
  final bool isOtherUser;

  const ProfileHeader({
    super.key,
    this.coverImage,
    this.isOtherUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
