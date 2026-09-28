import 'package:aicc/core/responsive/responsive_breakpoints.dart';
import 'package:flutter/material.dart';

class PortfolioHeader extends StatelessWidget {
  const PortfolioHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    return Row(
      children: [
        Text(
          "Portfolio",
          style: TextStyle(
            color: isDesktop ? const Color(0xFF0F172A) : Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
      ],
    );
  }
}