import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:aicc/core/constants/app_colors.dart';

class ArtistInfo extends StatelessWidget {
  final String? name;
  final String? state;
  final String? city;
  final String? plan;
  final bool isVerified;
  
  const ArtistInfo({
    super.key,
    this.name,
    this.state,
    this.city,
    this.plan,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    String location = "";
    if (city != null && city!.isNotEmpty && state != null && state!.isNotEmpty) {
      location = '$city, $state';
    } else if (city != null && city!.isNotEmpty) {
      location = city!;
    } else if (state != null && state!.isNotEmpty) {
      location = state!;
    } else {
      location = 'Location not available';
    }

    final hasPlan = plan != null &&
        plan!.trim().isNotEmpty &&
        plan!.trim().toLowerCase() != 'free' &&
        plan!.trim().toLowerCase() != 'none';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Text(
              name?.isNotEmpty == true ? name! : "Unknown",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
            if (hasPlan)
              _buildPlanBadge(plan!.trim())
            else if (isVerified)
              const Icon(
                Icons.verified_rounded,
                color: Color(0xFF38BDF8),
                size: 22,
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 18,
              color: AppColors.greyText,
            ),
            const SizedBox(width: 4),
            Text(
              location,
              style: const TextStyle(
                color: AppColors.greyText,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlanBadge(String planKey) {
    final isProMax = planKey.toLowerCase().contains('max');
    final label = isProMax ? 'PRO MAX' : 'PRO';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isProMax
              ? const [Color(0xFFE11D48), Color(0xFF9333EA)]
              : const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isProMax
              ? const Color(0xFFFDA4AF).withValues(alpha: 0.8)
              : const Color(0xFFDDD6FE).withValues(alpha: 0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isProMax ? const Color(0xFFE11D48) : const Color(0xFF8B5CF6))
                .withValues(alpha: 0.45),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FaIcon(
            FontAwesomeIcons.crown,
            color: Color(0xFFFDE047),
            size: 11,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
          // const SizedBox(width: 4),
          // const Icon(
          //   Icons.verified_rounded,
          //   color: Colors.white,
          //   size: 13,
          // ),
        ],
      ),
    );
  }
}