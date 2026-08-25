import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/apply_job_provider.dart';

class AppliedAuditionsScreen extends StatefulWidget {
  const AppliedAuditionsScreen({super.key});

  @override
  State<AppliedAuditionsScreen> createState() => _AppliedAuditionsScreenState();
}

class _AppliedAuditionsScreenState extends State<AppliedAuditionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplyJobProvider>().fetchMyApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ApplyJobProvider>();
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1F5A6A),
            Color(0xFF123B4A),
            Color(0xFF0B1F2A),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          "Applied Auditions",
          style: textTheme.titleLarge,
        ),
      ),
      body: provider.isFetchingApplications
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : provider.applications.isEmpty
              ? Center(
                  child: Text(
                    "No applied auditions found.",
                    style: textTheme.bodyMedium,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: provider.applications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final app = provider.applications[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.border,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.auditionTitle.isNotEmpty ? app.auditionTitle : "Unknown Title",
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Role: ${app.role.isNotEmpty ? app.role : "N/A"}",
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Status: ${app.status.toUpperCase()}",
                                style: textTheme.labelLarge?.copyWith(
                                  color: app.status.toLowerCase() == 'pending'
                                      ? AppColors.warning
                                      : app.status.toLowerCase() == 'accepted'
                                          ? AppColors.success
                                          : AppColors.danger,
                                ),
                              ),
                              if (app.appliedDate.isNotEmpty)
                                Text(
                                  "Applied: ${app.appliedDate.split('T').first}",
                                  style: textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
