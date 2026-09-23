import 'subscription_plan_model.dart';

class DailyUsage {
  final int likes;
  final int comments;
  final int profileViews;
  final int scrollProfiles;
  final int messages;
  final int auditionApplications;

  const DailyUsage({
    this.likes = 0,
    this.comments = 0,
    this.profileViews = 0,
    this.scrollProfiles = 0,
    this.messages = 0,
    this.auditionApplications = 0,
  });

  DailyUsage copyWith({
    int? likes,
    int? comments,
    int? profileViews,
    int? scrollProfiles,
    int? messages,
    int? auditionApplications,
  }) {
    return DailyUsage(
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      profileViews: profileViews ?? this.profileViews,
      scrollProfiles: scrollProfiles ?? this.scrollProfiles,
      messages: messages ?? this.messages,
      auditionApplications: auditionApplications ?? this.auditionApplications,
    );
  }

  factory DailyUsage.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DailyUsage();
    return DailyUsage(
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      profileViews: json['profileViews'] as int? ?? 0,
      scrollProfiles: (json['scrollProfiles'] ?? json['profileScrolls']) as int? ?? 0,
      messages: json['messages'] as int? ?? 0,
      auditionApplications: json['auditionApplications'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'likes': likes,
      'comments': comments,
      'profileViews': profileViews,
      'scrollProfiles': scrollProfiles,
      'messages': messages,
      'auditionApplications': auditionApplications,
    };
  }
}

class ContentLimits {
  final int? photosPerDay;
  final int? videosPerWeek;
  final int? auditionsPerWeek;

  const ContentLimits({
    this.photosPerDay,
    this.videosPerWeek,
    this.auditionsPerWeek,
  });

  factory ContentLimits.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ContentLimits();
    return ContentLimits(
      photosPerDay: json['photosPerDay'] as int?,
      videosPerWeek: json['videosPerWeek'] as int?,
      auditionsPerWeek: json['auditionsPerWeek'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'photosPerDay': photosPerDay,
      'videosPerWeek': videosPerWeek,
      'auditionsPerWeek': auditionsPerWeek,
    };
  }
}

class UserSubscriptionModel {
  final bool isPaid;
  final String plan;
  final String subscriptionStatus;
  final DateTime? currentPeriodEnd;
  final String? previousPlan;
  final DateTime? planChangedAt;
  final PlanLimits limits;
  final ContentLimits contentLimits;
  final DailyUsage usedToday;
  final DailyUsage remainingToday;
  final PaymentPlansResponse? paymentOptions;

  const UserSubscriptionModel({
    this.isPaid = false,
    this.plan = 'free',
    this.subscriptionStatus = 'inactive',
    this.currentPeriodEnd,
    this.previousPlan,
    this.planChangedAt,
    this.limits = const PlanLimits(),
    this.contentLimits = const ContentLimits(),
    this.usedToday = const DailyUsage(),
    this.remainingToday = const DailyUsage(),
    this.paymentOptions,
  });

  bool get isActive =>
      subscriptionStatus.toLowerCase() == 'active' || isPaid;

  String get planLabel {
    final lower = plan.toLowerCase().trim();
    if (lower == 'pro_max' || lower == 'promax') return 'Pro Max';
    if (lower == 'pro') return 'Pro';
    return 'Free';
  }

  UserSubscriptionModel copyWith({
    bool? isPaid,
    String? plan,
    String? subscriptionStatus,
    DateTime? currentPeriodEnd,
    String? previousPlan,
    DateTime? planChangedAt,
    PlanLimits? limits,
    ContentLimits? contentLimits,
    DailyUsage? usedToday,
    DailyUsage? remainingToday,
    PaymentPlansResponse? paymentOptions,
  }) {
    return UserSubscriptionModel(
      isPaid: isPaid ?? this.isPaid,
      plan: plan ?? this.plan,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      currentPeriodEnd: currentPeriodEnd ?? this.currentPeriodEnd,
      previousPlan: previousPlan ?? this.previousPlan,
      planChangedAt: planChangedAt ?? this.planChangedAt,
      limits: limits ?? this.limits,
      contentLimits: contentLimits ?? this.contentLimits,
      usedToday: usedToday ?? this.usedToday,
      remainingToday: remainingToday ?? this.remainingToday,
      paymentOptions: paymentOptions ?? this.paymentOptions,
    );
  }

  factory UserSubscriptionModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return null;
      }
    }

    final rawPlan = (json['plan'] ?? json['currentPlan'] ?? json['activePlan'] ?? 'free')
        .toString()
        .toLowerCase()
        .trim();

    // Limits
    PlanLimits planLimits;
    if (json['limits'] is Map<String, dynamic>) {
      planLimits = PlanLimits.fromJson(json['limits'] as Map<String, dynamic>);
    } else if (json['limits'] is Map) {
      planLimits = PlanLimits.fromJson(Map<String, dynamic>.from(json['limits'] as Map));
    } else {
      planLimits = _defaultLimitsForPlan(rawPlan);
    }

    // Used today
    DailyUsage used;
    if (json['usedToday'] is Map<String, dynamic>) {
      used = DailyUsage.fromJson(json['usedToday'] as Map<String, dynamic>);
    } else if (json['usedToday'] is Map) {
      used = DailyUsage.fromJson(Map<String, dynamic>.from(json['usedToday'] as Map));
    } else {
      used = const DailyUsage();
    }

    // Remaining today
    DailyUsage remaining;
    if (json['remainingToday'] is Map<String, dynamic>) {
      remaining = DailyUsage.fromJson(json['remainingToday'] as Map<String, dynamic>);
    } else if (json['remainingToday'] is Map) {
      remaining = DailyUsage.fromJson(Map<String, dynamic>.from(json['remainingToday'] as Map));
    } else {
      remaining = _defaultRemainingFromLimits(planLimits, used);
    }

    PaymentPlansResponse? paymentOptions;
    if (json['paymentOptions'] is Map<String, dynamic>) {
      paymentOptions = PaymentPlansResponse.fromJson(json['paymentOptions'] as Map<String, dynamic>);
    } else if (json['paymentOptions'] is Map) {
      paymentOptions = PaymentPlansResponse.fromJson(Map<String, dynamic>.from(json['paymentOptions'] as Map));
    }

    return UserSubscriptionModel(
      isPaid: json['isPaid'] as bool? ?? (rawPlan != 'free'),
      plan: rawPlan,
      subscriptionStatus: (json['subscriptionStatus'] ?? (rawPlan != 'free' ? 'active' : 'none')).toString(),
      currentPeriodEnd: parseDate(json['currentPeriodEnd']),
      previousPlan: json['previousPlan']?.toString(),
      planChangedAt: parseDate(json['planChangedAt']),
      limits: planLimits,
      contentLimits: json['contentLimits'] is Map
          ? ContentLimits.fromJson(Map<String, dynamic>.from(json['contentLimits'] as Map))
          : const ContentLimits(),
      usedToday: used,
      remainingToday: remaining,
      paymentOptions: paymentOptions,
    );
  }

  static PlanLimits _defaultLimitsForPlan(String plan) {
    if (plan.contains('max')) {
      return const PlanLimits(
        likesPerDay: 500,
        commentsPerDay: 100,
        profileViewsPerDay: 500,
        profileScrollsPerDay: 500,
        messagesPerDay: 500,
        auditionApplicationsPerDay: 50,
      );
    } else if (plan.contains('pro')) {
      return const PlanLimits(
        likesPerDay: 200,
        commentsPerDay: 30,
        profileViewsPerDay: 100,
        profileScrollsPerDay: 100,
        messagesPerDay: 50,
        auditionApplicationsPerDay: 10,
      );
    }
    return const PlanLimits(
      likesPerDay: 20,
      commentsPerDay: 5,
      profileViewsPerDay: 20,
      profileScrollsPerDay: 50,
      messagesPerDay: 5,
      auditionApplicationsPerDay: 1,
    );
  }

  static DailyUsage _defaultRemainingFromLimits(PlanLimits limits, DailyUsage used) {
    return DailyUsage(
      likes: (limits.likesPerDay - used.likes).clamp(0, 999999),
      comments: (limits.commentsPerDay - used.comments).clamp(0, 999999),
      profileViews: (limits.profileViewsPerDay - used.profileViews).clamp(0, 999999),
      scrollProfiles: (limits.profileScrollsPerDay - used.scrollProfiles).clamp(0, 999999),
      messages: (limits.messagesPerDay - used.messages).clamp(0, 999999),
      auditionApplications: (limits.auditionApplicationsPerDay - used.auditionApplications).clamp(0, 999999),
    );
  }

  factory UserSubscriptionModel.defaultFree() {
    const defaultLimits = PlanLimits(
      likesPerDay: 20,
      commentsPerDay: 5,
      profileViewsPerDay: 20,
      profileScrollsPerDay: 50,
      messagesPerDay: 5,
      auditionApplicationsPerDay: 1,
    );
    return const UserSubscriptionModel(
      isPaid: false,
      plan: 'free',
      subscriptionStatus: 'none',
      limits: defaultLimits,
      usedToday: DailyUsage(),
      remainingToday: DailyUsage(
        likes: 20,
        comments: 5,
        profileViews: 20,
        scrollProfiles: 50,
        messages: 5,
        auditionApplications: 1,
      ),
    );
  }
}
