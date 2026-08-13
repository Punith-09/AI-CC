
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLine(),

        const SizedBox(width: 13),

        Text(
          'AI-MATCHED AUDITIONS',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 15.5,
            letterSpacing: 2.1,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(width: 13),

        _buildLine(),
      ],
    );
  }

  Widget _buildLine() {
    return Container(
      width: 27,
      height: 2,
      decoration: BoxDecoration(
        color: const Color(0xFF9142E7),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}