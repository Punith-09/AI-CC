import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:aicc/core/constants/app_colors.dart';

class StepReadyView extends StatefulWidget {
  final VoidCallback onFinished;

  const StepReadyView({
    super.key,
    required this.onFinished,
  });

  @override
  State<StepReadyView> createState() => _StepReadyViewState();
}

class _StepReadyViewState extends State<StepReadyView>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );

    // 3 seconds auto-navigation back to artist profile screen
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onFinished();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final subTextColor =
        isDark ? Colors.white70 : const Color(0xFF4B5563);

    return Stack(
      children: [
        // Festive Confetti Background
        Positioned.fill(
          child: CustomPaint(
            painter: _ConfettiPainter(isDark: isDark),
          ),
        ),

        // Center celebration content
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? const Color(0xFF221A10)
                          : const Color(0xFFFFF4E5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFDC8B20)
                              .withValues(alpha: isDark ? 0.35 : 0.2),
                          blurRadius: 28,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '🎉',
                        style: TextStyle(fontSize: 44),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Your profile is ready!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'You\'re all set. Your profile is ready',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final bool isDark;
  _ConfettiPainter({required this.isDark});

  static final List<Color> _colors = [
    const Color(0xFFE53935), // red
    const Color(0xFF1E88E5), // blue
    const Color(0xFF43A047), // green
    const Color(0xFFFB8C00), // orange
    const Color(0xFF8E24AA), // purple
    const Color(0xFFFDD835), // yellow
    const Color(0xFF00ACC1), // cyan
    const Color(0xFFD81B60), // pink
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rand = math.Random(42); // fixed seed for stable confetti positioning
    final paint = Paint()..style = PaintingStyle.fill;

    const count = 46;
    for (int i = 0; i < count; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final c = _colors[rand.nextInt(_colors.length)];
      paint.color = c.withValues(alpha: isDark ? 0.75 : 0.65);

      final type = rand.nextInt(3);
      final angle = rand.nextDouble() * math.pi;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);

      if (type == 0) {
        // Little ribbon/rectangle
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset.zero,
                width: 5 + rand.nextDouble() * 6,
                height: 12 + rand.nextDouble() * 10),
            const Radius.circular(2),
          ),
          paint,
        );
      } else if (type == 1) {
        // Dot / circle
        canvas.drawCircle(Offset.zero, 3 + rand.nextDouble() * 3, paint);
      } else {
        // Little arc / curved strip
        final path = Path()
          ..moveTo(-4, -6)
          ..quadraticBezierTo(0, 0, 4, 6)
          ..lineTo(6, 4)
          ..quadraticBezierTo(2, -2, -2, -8)
          ..close();
        canvas.drawPath(path, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
