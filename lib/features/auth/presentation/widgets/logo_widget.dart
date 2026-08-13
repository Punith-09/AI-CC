import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'glow_dot.dart';
class LogoWidget extends StatelessWidget {
  const LogoWidget();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      height: 170,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Large subtle orbital circle
          Container(
            width: 165,
            height: 165,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0x142B8198),
                width: 1,
              ),
            ),
          ),

          // Second orbital circle
          Container(
            width: 125,
            height: 125,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0x101F7184),
                width: 1,
              ),
            ),
          ),

          // Purple dot
          Positioned(
            right: 8,
            top: 39,
            child: GlowDot(
              color: const Color(0xFF9B3CFF),
              size: 9,
            ),
          ),

          // Blue dot left
          Positioned(
            left: 7,
            bottom: 31,
            child: GlowDot(
              color: const Color(0xFF75BFFF),
              size: 8,
            ),
          ),

          // Blue dot right
          Positioned(
            right: 18,
            bottom: 21,
            child: GlowDot(
              color: const Color(0xFF65A8FF),
              size: 8,
            ),
          ),

          // Actual logo box
          Container(
            width: 142,
            height: 142,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF174452),
                  Color(0xFF0C2B35),
                  Color(0xFF071C25),
                ],
              ),
              border: Border.all(
                color: const Color(0xFF76DDF4),
                width: 1.3,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x6669DDF5),
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Color(0x4055C2D7),
                  blurRadius: 9,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Color(0xAA000000),
                  blurRadius: 16,
                  spreadRadius: 2,
                  offset: Offset(5, 8),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                LucideIcons.clapperboard,
                size: 67,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}