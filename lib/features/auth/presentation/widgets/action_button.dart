import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final LinearGradient? gradient;
  final Color? backgroundColor;
  final Color borderColor;
  final Color? glowColor;
  final VoidCallback onTap;

  const ActionButton({
    required this.title,
    required this.icon,
    required this.borderColor,
    required this.onTap,
    this.gradient,
    this.backgroundColor,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 84,
      decoration: BoxDecoration(
        gradient: gradient,
        color: backgroundColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: borderColor,
          width: 1.2,
        ),
        boxShadow: glowColor == null
            ? [
          const BoxShadow(
            color: Color(0x300B536A),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ]
            : [
          BoxShadow(
            color: glowColor!,
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          splashColor: Colors.white.withOpacity(.08),
          highlightColor: Colors.white.withOpacity(.04),
          onTap: onTap,
          child: Row(
            children: [
              const SizedBox(width: 23),

              // Icon circle
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0x18000000),
                  border: Border.all(
                    color: Colors.white.withOpacity(.12),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              ),

              const SizedBox(width: 23),

              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 32,
              ),

              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}
