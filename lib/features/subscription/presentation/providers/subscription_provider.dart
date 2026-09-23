import 'package:flutter/foundation.dart';
import '../../data/datasource/subscription_remote_datasource.dart';
import '../../data/models/subscription_plan_model.dart';
import '../../data/models/user_subscription_model.dart';

enum LimitType {
  auditionApplication,
  like,
  comment,
  message,
  profileView,
}

class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionRemoteDataSource _remoteDataSource;

  UserSubscriptionModel? _subscription;
  bool _isLoading = false;
  String? _error;

  SubscriptionProvider(this._remoteDataSource);

  UserSubscriptionModel? get subscription => _subscription;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get activePlan => (_subscription?.plan ?? 'free').toLowerCase().trim();
  String get planLabel => _subscription?.planLabel ?? 'Free';
  bool get isPaid => _subscription?.isPaid ?? false;

  PlanLimits get limits =>
      _subscription?.limits ?? UserSubscriptionModel.defaultFree().limits;

  DailyUsage get usedToday =>
      _subscription?.usedToday ?? const DailyUsage();

  DailyUsage get remainingToday =>
      _subscription?.remainingToday ??
      UserSubscriptionModel.defaultFree().remainingToday;

  // =========================================================
  // LIMIT CHECKS
  // =========================================================

  bool get canApplyAudition {
    // If not yet loaded, allow by default so we don't block users prematurely
    if (_subscription == null) return true;
    return remainingToday.auditionApplications > 0;
  }

  bool get canLike {
    if (_subscription == null) return true;
    return remainingToday.likes > 0;
  }

  bool get canComment {
    if (_subscription == null) return true;
    return remainingToday.comments > 0;
  }

  // =========================================================
  // OPTIMISTIC USAGE TRACKING & REVERTS
  // =========================================================

  void recordLikeUsed() {
    final cur = remainingToday;
    final used = usedToday;
    final newRemaining = cur.copyWith(
      likes: (cur.likes - 1).clamp(0, 999999),
    );
    final newUsed = used.copyWith(
      likes: used.likes + 1,
    );
    _subscription = (_subscription ?? UserSubscriptionModel.defaultFree()).copyWith(
      remainingToday: newRemaining,
      usedToday: newUsed,
    );
    notifyListeners();
  }

  void revertLikeUsed() {
    final cur = remainingToday;
    final used = usedToday;
    final newRemaining = cur.copyWith(
      likes: cur.likes + 1,
    );
    final newUsed = used.copyWith(
      likes: (used.likes - 1).clamp(0, 999999),
    );
    _subscription = (_subscription ?? UserSubscriptionModel.defaultFree()).copyWith(
      remainingToday: newRemaining,
      usedToday: newUsed,
    );
    notifyListeners();
  }

  void recordCommentUsed() {
    final cur = remainingToday;
    final used = usedToday;
    final newRemaining = cur.copyWith(
      comments: (cur.comments - 1).clamp(0, 999999),
    );
    final newUsed = used.copyWith(
      comments: used.comments + 1,
    );
    _subscription = (_subscription ?? UserSubscriptionModel.defaultFree()).copyWith(
      remainingToday: newRemaining,
      usedToday: newUsed,
    );
    notifyListeners();
  }

  void revertCommentUsed() {
    final cur = remainingToday;
    final used = usedToday;
    final newRemaining = cur.copyWith(
      comments: cur.comments + 1,
    );
    final newUsed = used.copyWith(
      comments: (used.comments - 1).clamp(0, 999999),
    );
    _subscription = (_subscription ?? UserSubscriptionModel.defaultFree()).copyWith(
      remainingToday: newRemaining,
      usedToday: newUsed,
    );
    notifyListeners();
  }

  void recordAuditionApplied() {
    final cur = remainingToday;
    final used = usedToday;
    final newRemaining = cur.copyWith(
      auditionApplications: (cur.auditionApplications - 1).clamp(0, 999999),
    );
    final newUsed = used.copyWith(
      auditionApplications: used.auditionApplications + 1,
    );
    _subscription = (_subscription ?? UserSubscriptionModel.defaultFree()).copyWith(
      remainingToday: newRemaining,
      usedToday: newUsed,
    );
    notifyListeners();
  }

  void revertAuditionApplied() {
    final cur = remainingToday;
    final used = usedToday;
    final newRemaining = cur.copyWith(
      auditionApplications: cur.auditionApplications + 1,
    );
    final newUsed = used.copyWith(
      auditionApplications: (used.auditionApplications - 1).clamp(0, 999999),
    );
    _subscription = (_subscription ?? UserSubscriptionModel.defaultFree()).copyWith(
      remainingToday: newRemaining,
      usedToday: newUsed,
    );
    notifyListeners();
  }

  void markLimitReached(LimitType type) {
    final cur = remainingToday;
    DailyUsage newRemaining;
    switch (type) {
      case LimitType.auditionApplication:
        newRemaining = cur.copyWith(auditionApplications: 0);
        break;
      case LimitType.like:
        newRemaining = cur.copyWith(likes: 0);
        break;
      case LimitType.comment:
        newRemaining = cur.copyWith(comments: 0);
        break;
      case LimitType.message:
        newRemaining = cur.copyWith(messages: 0);
        break;
      case LimitType.profileView:
        newRemaining = cur.copyWith(profileViews: 0);
        break;
    }
    _subscription = (_subscription ?? UserSubscriptionModel.defaultFree()).copyWith(
      remainingToday: newRemaining,
    );
    notifyListeners();
  }

  // =========================================================
  // FETCH / SYNC
  // =========================================================

  Future<void> fetchSubscription({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final sub = await _remoteDataSource.getUserSubscription();
      if (sub != null) {
        _subscription = sub;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void setSubscription(UserSubscriptionModel sub) {
    _subscription = sub;
    notifyListeners();
  }

  void setActivePlan(String plan) {
    final lower = plan.toLowerCase().trim();
    if (_subscription != null) {
      _subscription = _subscription!.copyWith(
        plan: lower,
        isPaid: lower != 'free',
        subscriptionStatus: lower != 'free' ? 'active' : 'none',
      );
    } else {
      _subscription = UserSubscriptionModel(
        plan: lower,
        isPaid: lower != 'free',
        subscriptionStatus: lower != 'free' ? 'active' : 'none',
      );
    }
    notifyListeners();
  }
}
