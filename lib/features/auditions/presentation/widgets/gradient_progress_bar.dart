import 'package:flutter/material.dart';

class GradientProgressBar extends StatelessWidget {
  final double value; // 0.0 - 1.0
  final double height;
  final List<Color> colors;
  final Color backgroundColor;
  final bool showPercentage;

  const GradientProgressBar({
    super.key,
    required this.value,
    this.height = 10,
    this.colors = const [
      Color(0xff8B5CF6),
      Color(0xffEC4899),
    ],
    this.backgroundColor = const Color(0xff343541),
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final progress = value.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Container(
                height: height,
                width: double.infinity,
                color: backgroundColor,
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colors,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colors.first.withOpacity(0.45),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showPercentage) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "${(progress * 100).round()}%",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ]
      ],
    );
  }
}