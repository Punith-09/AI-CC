import 'package:flutter/material.dart';

class ActivityEndText extends StatelessWidget {
  const ActivityEndText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Center(
        child: Text(
          "End of activity for now",
          style: TextStyle(
            color: Colors.white38,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
