class PlanLimits {
  final int likesPerDay;
  final int commentsPerDay;
  final int profileViewsPerDay;
  final int profileScrollsPerDay;
  final int messagesPerDay;
  final int auditionApplicationsPerDay;

  const PlanLimits({
    this.likesPerDay = 0,
    this.commentsPerDay = 0,
    this.profileViewsPerDay = 0,
    this.profileScrollsPerDay = 0,
    this.messagesPerDay = 0,
    this.auditionApplicationsPerDay = 0,
  });

  factory PlanLimits.fromJson(Map<String, dynamic> json) {
    return PlanLimits(
      likesPerDay: json['likesPerDay'] as int? ?? 0,
      commentsPerDay: json['commentsPerDay'] as int? ?? 0,
      profileViewsPerDay: json['profileViewsPerDay'] as int? ?? 0,
      profileScrollsPerDay: json['profileScrollsPerDay'] as int? ?? 0,
      messagesPerDay: json['messagesPerDay'] as int? ?? 0,
      auditionApplicationsPerDay: json['auditionApplicationsPerDay'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'likesPerDay': likesPerDay,
      'commentsPerDay': commentsPerDay,
      'profileViewsPerDay': profileViewsPerDay,
      'profileScrollsPerDay': profileScrollsPerDay,
      'messagesPerDay': messagesPerDay,
      'auditionApplicationsPerDay': auditionApplicationsPerDay,
    };
  }
}

class SubscriptionPlan {
  final String plan;
  final String label;
  final int amountPaise;
  final int amountRupees;
  final String currency;
  final int periodDays;
  final PlanLimits limits;

  const SubscriptionPlan({
    required this.plan,
    required this.label,
    required this.amountPaise,
    required this.amountRupees,
    required this.currency,
    required this.periodDays,
    required this.limits,
  });

  String get subtitle {
    if (plan.toLowerCase().contains('max')) {
      return 'For serious creators & professionals';
    }
    return 'Perfect for growing your presence';
  }

  String get periodLabel {
    if (periodDays == 30) {
      return '/ month';
    }
    return '/ $periodDays days';
  }

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      plan: json['plan'] as String? ?? '',
      label: json['label'] as String? ?? '',
      amountPaise: json['amountPaise'] as int? ?? 0,
      amountRupees: json['amountRupees'] as int? ?? ((json['amountPaise'] as int? ?? 0) ~/ 100),
      currency: json['currency'] as String? ?? 'INR',
      periodDays: json['periodDays'] as int? ?? 30,
      limits: json['limits'] != null
          ? PlanLimits.fromJson(json['limits'] as Map<String, dynamic>)
          : const PlanLimits(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan': plan,
      'label': label,
      'amountPaise': amountPaise,
      'amountRupees': amountRupees,
      'currency': currency,
      'periodDays': periodDays,
      'limits': limits.toJson(),
    };
  }
}

class PaymentPlansResponse {
  final String checkoutEndpoint;
  final String verifyEndpoint;
  final List<SubscriptionPlan> plans;
  final String recommendedPlan;

  const PaymentPlansResponse({
    required this.checkoutEndpoint,
    required this.verifyEndpoint,
    required this.plans,
    required this.recommendedPlan,
  });

  factory PaymentPlansResponse.fromJson(Map<String, dynamic> json) {
    final rawPlans = json['plans'] as List<dynamic>? ?? [];
    final plansList = rawPlans
        .map((p) => SubscriptionPlan.fromJson(p as Map<String, dynamic>))
        .toList();

    return PaymentPlansResponse(
      checkoutEndpoint: json['checkoutEndpoint'] as String? ?? '/payments/checkout',
      verifyEndpoint: json['verifyEndpoint'] as String? ?? '/payments/verify',
      plans: plansList,
      recommendedPlan: json['recommendedPlan'] as String? ?? 'pro',
    );
  }

  static PaymentPlansResponse defaultPlans() {
    return const PaymentPlansResponse(
      checkoutEndpoint: '/payments/checkout',
      verifyEndpoint: '/payments/verify',
      recommendedPlan: 'pro',
      plans: [
        SubscriptionPlan(
          plan: 'pro',
          label: 'Pro',
          amountPaise: 49900,
          amountRupees: 499,
          currency: 'INR',
          periodDays: 30,
          limits: PlanLimits(
            likesPerDay: 200,
            commentsPerDay: 30,
            profileViewsPerDay: 100,
            profileScrollsPerDay: 100,
            messagesPerDay: 50,
            auditionApplicationsPerDay: 10,
          ),
        ),
        SubscriptionPlan(
          plan: 'pro_max',
          label: 'Pro Max',
          amountPaise: 99900,
          amountRupees: 999,
          currency: 'INR',
          periodDays: 30,
          limits: PlanLimits(
            likesPerDay: 500,
            commentsPerDay: 100,
            profileViewsPerDay: 500,
            profileScrollsPerDay: 500,
            messagesPerDay: 500,
            auditionApplicationsPerDay: 50,
          ),
        ),
      ],
    );
  }
}

class CheckoutOrderResponse {
  final String keyId;
  final String orderId;
  final int amount;
  final String currency;
  final String plan;
  final String subscriptionId;

  const CheckoutOrderResponse({
    required this.keyId,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.plan,
    required this.subscriptionId,
  });

  factory CheckoutOrderResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutOrderResponse(
      keyId: json['keyId'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'INR',
      plan: json['plan'] as String? ?? '',
      subscriptionId: json['subscriptionId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keyId': keyId,
      'orderId': orderId,
      'amount': amount,
      'currency': currency,
      'plan': plan,
      'subscriptionId': subscriptionId,
    };
  }
}

class VerifyPaymentRequest {
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String razorpaySignature;

  const VerifyPaymentRequest({
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
  });

  Map<String, dynamic> toJson() {
    return {
      'razorpayOrderId': razorpayOrderId,
      'razorpayPaymentId': razorpayPaymentId,
      'razorpaySignature': razorpaySignature,
    };
  }
}

class VerifyPaymentResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  const VerifyPaymentResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory VerifyPaymentResponse.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return VerifyPaymentResponse(
        success: json['success'] as bool? ?? true,
        message: json['message'] as String? ?? 'Payment verified successfully',
        data: json,
      );
    }
    return const VerifyPaymentResponse(
      success: true,
      message: 'Payment verified successfully',
    );
  }
}

