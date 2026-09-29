import 'package:aicc/core/constants/app_colors.dart';
import 'package:aicc/core/responsive/responsive_breakpoints.dart';
import 'package:flutter/material.dart';
import '../widgets/activity_card.dart';
import '../widgets/activity_end_text.dart';
import '../widgets/activity_tab_bar.dart';
import '../../data/models/activity_model.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  int selectedTab = 0;

  final List<ActivityModel> activities = [
    ActivityModel(
      title: "Top AI Match for 'Lead'",
      subtitle: "Your profile is a 98% match in the 'Warrior Prince' role.",
      time: "2m ago",
      badge: "AI MATCH",
      badgeColor: Colors.amber,
      highlight: true,
    ),
    ActivityModel(
      title: "Application Viewed",
      subtitle: "Dharma Productions just viewed your profile.",
      time: "1h ago",
      badge: "APPLICATION",
      badgeColor: Colors.pink,
    ),
    ActivityModel(
      title: "AICC Verified!",
      subtitle: "Congratulations! Your profile has been officially verified.",
      time: "5h ago",
      badge: "VERIFICATION",
      badgeColor: Colors.deepPurple,
    ),
    ActivityModel(
      title: "New Follower",
      subtitle: "Casting Director Shanoo Sharma started following you.",
      time: "Yesterday",
      badge: "SOCIAL",
      badgeColor: Colors.deepPurple,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Column(
      children: [
        const SizedBox(height: 16),
        ActivityTabBar(
          selectedIndex: selectedTab,
          onChanged: (index) {
            setState(() {
              selectedTab = index;
            });
          },
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: activities.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              if (index == activities.length) {
                return const ActivityEndText();
              }

              return ActivityCard(activity: activities[index]);
            },
          ),
        ),
      ],
    );

    if (isDesktop) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: content,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Activity",
          style: TextStyle(
            color: isDark ? AppColors.darkText : AppColors.lightText,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                color: isDark ? AppColors.darkText : AppColors.lightText,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: content,
      ),
    );
  }
}
