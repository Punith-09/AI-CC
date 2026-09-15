import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SubscriptionButton extends StatelessWidget {
  final VoidCallback onTap;
  final String? activePlan;

  const SubscriptionButton({
    super.key,
    required this.onTap,
    this.activePlan,
  });

  @override
  Widget build(BuildContext context) {
    final hasActivePlan = activePlan != null &&
        activePlan!.trim().isNotEmpty &&
        activePlan!.trim().toLowerCase() != 'free' &&
        activePlan!.trim().toLowerCase() != 'none';

    final isProMax = hasActivePlan && activePlan!.toLowerCase().contains('max');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: hasActivePlan
              ? (isProMax
                  ? const [Color(0xFFBE185D), Color(0xFF7E22CE)]
                  : const [Color(0xFF7C3AED), Color(0xFF4C1D95)])
              : const [Color(0xFFA855F7), Color(0xFF6B21A8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: hasActivePlan
            ? Border.all(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
                width: 1.2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: (hasActivePlan
                    ? const Color(0xFF8B5CF6)
                    : const Color(0xFF9333EA))
                .withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasActivePlan
                          ? const Color(0xFF38BDF8).withValues(alpha: 0.4)
                          : Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.crown,
                      color: hasActivePlan
                          ? const Color(0xFFFDE047)
                          : Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            hasActivePlan
                                ? "${isProMax ? 'Pro Max' : 'Pro'} Member"
                                : "Get Subscription",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            hasActivePlan
                                ? Icons.verified_rounded
                                : Icons.stars_rounded,
                            color: hasActivePlan
                                ? const Color(0xFF38BDF8)
                                : const Color(0xFFFDE047),
                            size: 16,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasActivePlan
                            ? "Active plan benefits • Tap to view or upgrade"
                            : "Unlock full potential & verified badge",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: hasActivePlan
                        ? const Color(0xFF22C55E).withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hasActivePlan
                        ? Icons.check_rounded
                        : Icons.arrow_forward_rounded,
                    color: hasActivePlan
                        ? const Color(0xFF4ADE80)
                        : Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
