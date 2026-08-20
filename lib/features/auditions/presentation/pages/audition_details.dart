import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../common/widgets/app_background.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../data/models/audition_model.dart';
import '../providers/auditions_provider.dart';
import '../widgets/bottom_action_bar.dart';
import '../widgets/detail_card.dart';
import '../widgets/info_tile.dart';
import '../widgets/section_title.dart';

class AuditionDetails extends StatefulWidget {
  final AuditionModel? audition;
  final String? auditionId;

  const AuditionDetails({
    super.key,
    this.audition,
    this.auditionId,
  });

  @override
  State<AuditionDetails> createState() => _AuditionDetailsState();
}

class _AuditionDetailsState extends State<AuditionDetails> {
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
  void initState() {
    super.initState();
    final targetId = widget.auditionId ?? widget.audition?.id;
    if (targetId != null && targetId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AuditionsProvider>().fetchAuditionById(
              targetId,
              initialData: widget.audition,
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auditionsProvider = context.watch<AuditionsProvider>();
    final item = auditionsProvider.selectedAudition ?? widget.audition ?? _defaultAudition;
    final isLoading = auditionsProvider.isDetailLoading && auditionsProvider.selectedAudition == null;
    final errorMessage = auditionsProvider.detailErrorMessage;

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
                        LucideIcons.chevronLeft,
                        color: AppColors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRoutes.auditions);
                        }
                      },
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

              if (isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              else if (errorMessage != null && auditionsProvider.selectedAudition == null)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            errorMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              final targetId = widget.auditionId ?? widget.audition?.id;
                              if (targetId != null) {
                                context.read<AuditionsProvider>().fetchAuditionById(targetId);
                              }
                            },
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
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
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (item.applied)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.green),
                                      ),
                                      child: const Text(
                                        "Applied",
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.createdAt.isNotEmpty
                                    ? "Posted on ${item.createdAt.split('T').first}"
                                    : "Recently posted",
                                style: const TextStyle(color: AppColors.greyText),
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
                                value: item.category.isNotEmpty ? item.category : "N/A",
                              ),
                              InfoTile(
                                icon: Icons.groups,
                                label: "Role",
                                value: item.role.isNotEmpty ? item.role : "N/A",
                              ),
                              InfoTile(
                                icon: Icons.language,
                                label: "Language",
                                value: item.language.isNotEmpty ? item.language : "N/A",
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
                                value: item.pay.isNotEmpty ? item.pay : "N/A",
                              ),
                              InfoTile(
                                icon: Icons.location_on_outlined,
                                label: "Location",
                                value: item.location.isNotEmpty ? item.location : "N/A",
                              ),
                              InfoTile(
                                icon: Icons.hourglass_bottom,
                                label: "Deadline",
                                value: item.deadline.isNotEmpty ? item.deadline : "N/A",
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        const SectionTitle(title: "JOB DETAILS & SPEC"),

                        DetailCard(
                          child: Text(
                            item.description.isNotEmpty ? item.description : "No description provided.",
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
                                label: "Contact Person",
                                value: item.effectiveContact,
                              ),
                              if (item.phone.isNotEmpty)
                                InfoTile(
                                  icon: Icons.phone_outlined,
                                  label: "Phone",
                                  value: item.phone,
                                ),
                              if (item.email.isNotEmpty)
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

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: BottomActionBar(audition: item),
              ),
              const SizedBox(height: 10)
            ],
          ),
        ),
      ),
    );
  }
}
