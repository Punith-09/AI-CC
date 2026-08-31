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
    pay: "₹15,000",
    location: "Bangalore",
    deadline: "2026-11-20",
    description:
        "High energy, urban hip hop back-up dancers needed for a prominent music label's latest pop single.",
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFE2A03F)),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFB0B6C4),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value.isNotEmpty ? value : "N/A",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantCard(ApplicantModel applicant) {
    Color statusColor;
    switch (applicant.status.toUpperCase()) {
      case 'APPROVED':
      case 'ACCEPTED':
        statusColor = Colors.greenAccent;
        break;
      case 'REJECTED':
        statusColor = Colors.redAccent;
        break;
      case 'PENDING':
      default:
        statusColor = Colors.amberAccent;
        break;
    }

    final dateStr = applicant.appliedDate.isNotEmpty
        ? applicant.appliedDate.split('T').first
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF143E4D).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                child: Text(
                  applicant.name.isNotEmpty ? applicant.name[0].toUpperCase() : 'A',
                  style: const TextStyle(
                    color: Color(0xFFC4B5FD),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      applicant.name.isNotEmpty ? applicant.name : 'Applicant',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (dateStr.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Applied on $dateStr',
                        style: const TextStyle(
                          color: Color(0xFF8B9CB0),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (applicant.category.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    applicant.category,
                    style: const TextStyle(
                      color: Color(0xFFD8B4FE),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withValues(alpha: 0.6)),
                ),
                child: Text(
                  applicant.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (applicant.coverLetter.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Cover Letter:",
                    style: TextStyle(
                      color: Color(0xFFB0B6C4),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    applicant.coverLetter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (applicant.details.isNotEmpty && applicant.details != applicant.coverLetter) ...[
            const SizedBox(height: 8),
            Text(
              applicant.details,
              style: const TextStyle(
                color: Color(0xFFB0B6C4),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auditionsProvider = context.watch<AuditionsProvider>();
    final item = auditionsProvider.selectedAudition ?? widget.audition ?? _defaultAudition;
    final isLoading = auditionsProvider.isDetailLoading && auditionsProvider.selectedAudition == null;
    final errorMessage = auditionsProvider.detailErrorMessage;

    final isMyAudition = item.createdByMe ||
        auditionsProvider.myPostedAuditions.any((a) => a.id == item.id);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              /// Top Bar Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRoutes.auditions);
                        }
                      },
                      icon: const Icon(
                        LucideIcons.arrowLeft,
                        color: AppColors.white,
                        size: 20,
                      ),
                      label: const Text(
                        "Back",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        "Audition Details",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 80),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),

                        /// Category Pill
                        if (item.category.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              item.category,
                              style: const TextStyle(
                                color: Color(0xFFC4B5FD),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        const SizedBox(height: 12),

                        /// Title
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        /// Role
                        if (item.role.isNotEmpty)
                          Text(
                            item.role,
                            style: const TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                        const SizedBox(height: 4),

                        /// Posted by
                        Text(
                          item.effectiveContact != 'N/A'
                              ? "Posted by ${item.effectiveContact}"
                              : (item.createdAt.isNotEmpty
                                  ? "Posted on ${item.createdAt.split('T').first}"
                                  : "Recently posted"),
                          style: const TextStyle(
                            color: Color(0xFF8B9CB0),
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// Info Card (Location, Pay, Deadline, Language)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF143E4D).withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow(Icons.location_on_outlined, "Location", item.location),
                              const Divider(color: Colors.white12, height: 1),
                              _buildInfoRow(Icons.currency_rupee, "Pay", item.pay),
                              const Divider(color: Colors.white12, height: 1),
                              _buildInfoRow(Icons.calendar_today_outlined, "Deadline", item.deadline),
                              const Divider(color: Colors.white12, height: 1),
                              _buildInfoRow(Icons.videocam_outlined, "Language", item.language),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// Description Section
                        const Text(
                          "Description",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.description.isNotEmpty
                              ? item.description
                              : "No description provided.",
                          style: const TextStyle(
                            color: Color(0xFFCBD5E1),
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 28),

                        /// Applicants Section
                        Text(
                          "Applicants (${item.applicantsCount})",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (item.applicants.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              "No applicants yet.",
                              style: TextStyle(
                                color: Color(0xFF8B9CB0),
                                fontSize: 14,
                              ),
                            ),
                          )
                        else
                          ...item.applicants.map((applicant) => _buildApplicantCard(applicant)),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

              /// Show apply bar only if it's NOT posted by the current user
              if (!isMyAudition) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: BottomActionBar(audition: item),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
