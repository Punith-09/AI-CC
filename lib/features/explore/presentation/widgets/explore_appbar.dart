import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

import "../../../../core/constants/app_colors.dart";

class ExploreAppbar extends StatelessWidget {
  const ExploreAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Text(
        "Explore Talent",
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.white : AppColors.black,
          fontSize: 22,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}