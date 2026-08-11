import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnalyticsCard extends StatelessWidget {
  const AnalyticsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff4B1D8A),
            Color(0xff2C0C55),
          ],
        ),
      ),
      child: Stack(
        children: [

          /// Decorative AI Icon
          Positioned(
            right: -10,
            top: -10,
            child: Icon(
              Icons.auto_awesome,
              size: 110,
              color: Colors.white.withOpacity(.08),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                "AUDITION ANALYSIS",
                style: TextStyle(
                  color: Colors.white.withOpacity(.7),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Protagonist:\nShadow of Mumbai",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 25),

              Row(
                children: [

                  Expanded(
                    child: analyticsItem(
                      icon: Icons.people_alt_outlined,
                      value: "142",
                      title: "Applied",
                      iconColor: Colors.amber,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: analyticsItem(
                      icon: Icons.trending_up,
                      value: "12",
                      title: "Top Fits",
                      iconColor: Colors.pinkAccent,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: analyticsItem(
                      icon: Icons.work_outline,
                      value: "84%",
                      title: "Avg. Match",
                      iconColor: Colors.amber,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

    );
  }

  Widget analyticsItem({
    required IconData icon,
    required String value,
    required String title,
    required Color iconColor,
  }) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(.08),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Icon(
            icon,
            color: iconColor,
            size: 24,
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(.75),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget statCard(
      IconData icon,
      String value,
      String title,
      Color iconColor,
      bool outlined,
      ) {
    return Container(
      height: 118,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.10),
        borderRadius: BorderRadius.circular(18),
        border: outlined
            ? Border.all(
          color: Colors.white24,
        )
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Icon(
            icon,
            color: iconColor,
            size: 24,
          ),

          const SizedBox(height: 12),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(.65),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
