import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/app_background.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../data/models/audition_model.dart';
import '../widgets/bottom_action_bar.dart';
import '../widgets/detail_card.dart';
import '../widgets/info_tile.dart';
import '../widgets/section_title.dart';

class AuditionDetails extends StatelessWidget {
  final AuditionModel? audition;

  const AuditionDetails({
    super.key,
    this.audition,
  });

  static final AuditionModel _defaultAudition = const AuditionModel(
    id: "1",
    title: "Music Video Backup Dancer",
    category: "Dancer",
    role: "Hip Hop Choreography Crew",
    language: "N/A",
    pay: "₹15,000 project payout",
    location: "Bangalore",
    deadline: "2026-11-20",
    description:
        "High energy, urban hip hop back-up dancers needed for a prominent music label's latest pop single. Fast pacing learning and coordination ability are required.",
    director: "Pulse Studios",
    phone: "+91 98765 43210",
    email: "producer@email.com",
  );

  @override
  Widget build(BuildContext context) {
    final item = audition ?? _defaultAudition;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.white,
                      ),
                      onPressed: () => context.go(AppRoutes.auditions),
                    ),
                    const Expanded(
                      child: Text(
                        "Audition Spec",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DetailCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 22,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Posted 1 week ago",
                              style: TextStyle(color: AppColors.greyText),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      const SectionTitle(title: "PROJECT INFORMATION"),

                      DetailCard(
                        child: Column(
                          children: [
                            InfoTile(
                              icon: Icons.movie_creation_outlined,
                              label: "Category",
                              value: item.category,
                            ),
                            InfoTile(
                              icon: Icons.groups,
                              label: "Role",
                              value: item.role,
                            ),
                            InfoTile(
                              icon: Icons.language,
                              label: "Language",
                              value: item.language,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      const SectionTitle(title: "COMPENSATION & GEOGRAPHY"),

                      DetailCard(
                        child: Column(
                          children: [
                            InfoTile(
                              icon: Icons.currency_rupee,
                              label: "Pay Scale",
                              value: item.pay,
                            ),
                            InfoTile(
                              icon: Icons.location_on_outlined,
                              label: "Location",
                              value: item.location,
                            ),
                            InfoTile(
                              icon: Icons.hourglass_bottom,
                              label: "Deadline",
                              value: item.deadline,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      const SectionTitle(title: "JOB DETAILS & SPEC"),

                      DetailCard(
                        child: Text(
                          item.description,
                          style: const TextStyle(
                            color: AppColors.greyText,
                            fontSize: 15,
                            height: 1.7,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      const SectionTitle(title: "CONTACT PRODUCER"),

                      DetailCard(
                        child: Column(
                          children: [
                            InfoTile(
                              icon: Icons.person_outline,
                              label: "Director",
                              value: item.director,
                            ),
                            InfoTile(
                              icon: Icons.phone_outlined,
                              label: "Phone",
                              value: item.phone,
                            ),
                            InfoTile(
                              icon: Icons.email_outlined,
                              label: "Email",
                              value: item.email,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: BottomActionBar(),
              ),
              const SizedBox(height: 10)
            ],
          ),
        ),
      ),
    );
  }
}
