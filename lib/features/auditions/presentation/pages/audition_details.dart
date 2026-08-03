import 'package:aicc/common/widgets/app_background.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/bottom_action_bar.dart';
import '../widgets/detail_card.dart';
import '../widgets/info_tile.dart';
import '../widgets/section_title.dart';
import '../../data/models/audition_model.dart';

class AuditionDetails extends StatelessWidget {
  AuditionDetails({super.key});

  final audition = AuditionModel(
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
                      onPressed: () => context.go("/auditions")
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
                              audition.title,
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
                              value: audition.category,
                            ),
                            InfoTile(
                              icon: Icons.groups,
                              label: "Role",
                              value: audition.role,
                            ),
                            InfoTile(
                              icon: Icons.language,
                              label: "Language",
                              value: audition.language,
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
                              value: audition.pay,
                            ),
                            InfoTile(
                              icon: Icons.location_on_outlined,
                              label: "Location",
                              value: audition.location,
                            ),
                            InfoTile(
                              icon: Icons.hourglass_bottom,
                              label: "Deadline",
                              value: audition.deadline,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      const SectionTitle(title: "JOB DETAILS & SPEC"),

                      DetailCard(
                        child: Text(
                          audition.description,
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
                              value: audition.director,
                            ),
                            InfoTile(
                              icon: Icons.phone_outlined,
                              label: "Phone",
                              value: audition.phone,
                            ),
                            InfoTile(
                              icon: Icons.email_outlined,
                              label: "Email",
                              value: audition.email,
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
              SizedBox(height: 10)
            ],
          ),
        ),
      ),
    );
  }
}
