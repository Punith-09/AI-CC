import 'package:flutter/material.dart';

import 'package:aicc/core/constants/app_colors.dart';

class AuditionCard extends StatelessWidget {
  final String title;
  final String category;
  final String location;
  final String deadline;
  final String payout;
  final String applicants;
  final String description;

  final VoidCallback onView;
  final VoidCallback onApply;

  const AuditionCard({
    super.key,
    required this.title,
    required this.category,
    required this.location,
    required this.deadline,
    required this.payout,
    required this.applicants,
    required this.description,
    required this.onView,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 22),
      decoration: BoxDecoration(
        color: Color(0xFF0E2730),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primary,
          width: 1.0
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Title + Deadline
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Expanded(
                child: Text(
                  title,
                  style:  TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,

                  ),
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [

                  Text(
                    "Deadline",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    deadline,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            ],
          ),

          const SizedBox(height: 14),

          /// Category
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              category,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 18),

          Wrap(
            spacing: 18,
            runSpacing: 12,
            children: [

              info(Icons.groups_2, payout),

              info(Icons.location_on_outlined, location),

              info(Icons.currency_rupee, payout),

              info(Icons.people_alt_outlined, applicants),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            description,
            style: TextStyle(
              color:AppColors.white,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 22),

          Row(
            children: [

              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: onView,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFF06233E),
                      side: BorderSide(
                        color: AppColors.primary,
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "View details",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),


              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primary,
                        // AppColors.secondary,
                        AppColors.gradient
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: onApply,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "APPLY NOW",

                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget info(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [

        Icon(
          icon,
          size: 18,
          // color: Colors.black87,
        ),

        const SizedBox(width: 5),

        Text(
          text,
          style: const TextStyle(fontSize: 14,color: AppColors.white),
        ),
      ],
    );
  }
}