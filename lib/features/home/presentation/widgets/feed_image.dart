import 'package:flutter/material.dart';

class FeedImage extends StatelessWidget {

  final String image;

  const FeedImage({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {

    return ClipRRect(

      // borderRadius: BorderRadius.circular(18),

      child: Image.asset(
        image,
        width: double.infinity,
        height: 240,
        fit: BoxFit.cover,
      ),

    );

  }
}