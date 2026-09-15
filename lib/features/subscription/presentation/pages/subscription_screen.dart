import 'package:aicc/common/widgets/app_background.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../artist_profile/presentation/providers/profile_provider.dart';
import '../../data/datasource/subscription_remote_datasource.dart';
import '../../data/models/subscription_plan_model.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  late final SubscriptionRemoteDataSource _remoteDataSource;
  PaymentPlansResponse _plansResponse = PaymentPlansResponse.defaultPlans();
  late String _selectedPlan;
  bool _isLoading = false;
  Map<String, dynamic>? _mySubscription;

  String? get _currentActivePlan {
    try {
      final profilePlan = context.read<ProfileProvider>().myActivePlan;
      if (profilePlan != null &&
          profilePlan.trim().isNotEmpty &&
          profilePlan.trim().toLowerCase() != 'free') {
        return profilePlan.trim().toLowerCase();
      }
    } catch (_) {}

    if (_mySubscription == null) return null;
    final subMap = _mySubscription?['subscription'];
    final plan = _mySubscription?['plan'] ??
        _mySubscription?['currentPlan'] ??
        _mySubscription?['activePlan'] ??
        (subMap is Map ? subMap['plan'] : null);
    if (plan != null &&
        plan.toString().trim().isNotEmpty &&
        plan.toString().trim().toLowerCase() != 'free') {
      return plan.toString().trim().toLowerCase();
    }
    return null;
  }

  bool _isPlanDowngrade(SubscriptionPlan targetPlan) {
    final current = _currentActivePlan;
    if (current == null || current.isEmpty || current.toLowerCase() == 'free') {
      return false;
    }

    if (current.toLowerCase() == targetPlan.plan.toLowerCase()) {
      return false;
    }

    final currentPlanObj = _getPlan(current);
    if (currentPlanObj != null) {
      return targetPlan.amountPaise < currentPlanObj.amountPaise;
    }

    final currentLower = current.toLowerCase();
    final targetLower = targetPlan.plan.toLowerCase();
    if (currentLower.contains('max') && !targetLower.contains('max')) {
      return true;
    }
    return false;
  }

  bool _isDowngradeError(dynamic error) {
    if (error is DioException) {
      if (error.response?.statusCode == 403) return true;
      final data = error.response?.data;
      if (data is Map) {
        final msg = (data['message'] ?? data['error'] ?? data['detail'] ?? '')
            .toString()
            .toLowerCase();
        if (msg.contains('downgrade') ||
            msg.contains('higher') ||
            msg.contains('lower') ||
            msg.contains('forbidden')) {
          return true;
        }
      }
    }
    final raw = error.toString().toLowerCase();
    return raw.contains('403') ||
        raw.contains('downgrade') ||
        raw.contains('downgrade_not_allowed');
  }

  String _getReadableErrorMessage(
    dynamic error, {
    String defaultMessage = 'Checkout failed. Please try again.',
  }) {
    if (error is DioException) {
      final responseData = error.response?.data;
      if (responseData is Map) {
        final msg = responseData['message']?.toString() ??
            responseData['error']?.toString() ??
            responseData['detail']?.toString() ??
            responseData['msg']?.toString();
        if (msg != null &&
            msg.trim().isNotEmpty &&
            !msg.toLowerCase().contains('internal server error') &&
            !msg.toLowerCase().contains('dioexception') &&
            !msg.toLowerCase().contains('validatestatus')) {
          return msg.trim();
        }
      } else if (responseData is String &&
          responseData.trim().isNotEmpty &&
          !responseData.contains('<!DOCTYPE') &&
          !responseData.contains('<html')) {
        final clean = responseData.trim();
        if (!clean.toLowerCase().contains('dioexception') &&
            !clean.toLowerCase().contains('validatestatus')) {
          return clean;
        }
      }

      final statusCode = error.response?.statusCode;
      if (statusCode == 403) {
        return 'You already have an active subscription with a higher-tier plan. Downgrading to a lower plan is not permitted.';
      } else if (statusCode == 400) {
        return 'Invalid checkout request. Please select a valid plan.';
      } else if (statusCode == 401) {
        return 'Session expired. Please log in again to proceed.';
      } else if (statusCode == 404) {
        return 'The selected subscription plan is currently unavailable.';
      } else if (statusCode == 409) {
        return 'You already have this subscription plan active.';
      } else if (statusCode != null && statusCode >= 500) {
        return 'Payment server is temporarily unavailable. Please try again in a moment.';
      } else if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError) {
        return 'Network connection error. Please check your internet connection.';
      }
    }

    final raw = error.toString().replaceAll('Exception: ', '').trim();
    if (raw.contains('downgrade_not_allowed') || raw.contains('403')) {
      return 'You already have an active subscription with a higher-tier plan. Downgrading to a lower plan is not allowed.';
    }
    if (raw.contains('DioException') ||
        raw.contains('validateStatus') ||
        raw.contains('Client error') ||
        raw.isEmpty) {
      return defaultMessage;
    }
    return raw;
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E293B),
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded,
                color: Color(0xFFF87171), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
      ),
    );
  }

  void _showDowngradeDialog(SubscriptionPlan targetPlan) {
    final currentPlanKey = _currentActivePlan ?? '';
    final currentPlanObj = _getPlan(currentPlanKey);
    final currentPlanName = currentPlanObj?.label ??
        (currentPlanKey.toLowerCase().contains('max') ? 'Pro Max' : 'Pro');

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF0A222E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF201338),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.crown,
                  color: Color(0xFFFDE047),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Downgrade Not Allowed',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF061821),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF133644),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Current Plan: ',
                        style: TextStyle(
                          color: Color(0xFF8FA7B2),
                          fontSize: 13,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFF22C55E),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          currentPlanName,
                          style: const TextStyle(
                            color: Color(0xFF4ADE80),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'You already have an active $currentPlanName subscription. Switching or downgrading to ${targetPlan.label} is not permitted while your current subscription is running.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF8FA7B2),
                      fontSize: 12.5,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(dialogCtx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Understood',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrentPlanInfoDialog(SubscriptionPlan plan) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF0A222E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: const Color(0xFF22C55E).withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF0A2E1C),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF4ADE80),
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              '${plan.label} is Active',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'You are already subscribed to the ${plan.label} plan and enjoying all its premium benefits.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF8FA7B2),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(dialogCtx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Great!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  late Razorpay _razorpay;
  SubscriptionPlan? _activePaymentPlan;
  CheckoutOrderResponse? _activeCheckoutOrder;

  @override
  void initState() {
    super.initState();
    _remoteDataSource = sl.isRegistered<SubscriptionRemoteDataSource>()
        ? sl<SubscriptionRemoteDataSource>()
        : SubscriptionRemoteDataSource(
            sl.isRegistered<DioClient>() ? sl<DioClient>() : DioClient(),
          );

    _selectedPlan = _plansResponse.recommendedPlan;
    _initRazorpay();
    _fetchPlans();
  }

  void _initRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _fetchPlans() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        _remoteDataSource.getPlans(),
        _remoteDataSource.getMySubscription(),
      ]);

      if (mounted) {
        final response = results[0] as PaymentPlansResponse;
        final mySub = results[1] as Map<String, dynamic>?;

        setState(() {
          _plansResponse = response;
          _mySubscription = mySub;
          if (!response.plans.any((p) => p.plan == _selectedPlan)) {
            _selectedPlan = response.recommendedPlan;
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  SubscriptionPlan? _getPlan(String planKey) {
    try {
      return _plansResponse.plans.firstWhere((p) => p.plan == planKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> _startRazorpayCheckout(
    SubscriptionPlan plan, {
    VoidCallback? onBeforeOpen,
  }) async {
    _activePaymentPlan = plan;

    final order = await _remoteDataSource.createCheckoutOrder(
      plan: plan.plan,
      endpoint: _plansResponse.checkoutEndpoint,
    );

    _activeCheckoutOrder = order;

    onBeforeOpen?.call();

    final userEmail = LocalStorage.instance.getUserEmail() ?? '';
    final userName = LocalStorage.instance.getUserName() ?? '';

    final options = {
      'key': order.keyId,
      'amount': order.amount,
      'name': 'AI Casting Club',
      'description': '${plan.label} Subscription',
      'order_id': order.orderId,
      'currency': order.currency.isNotEmpty ? order.currency : 'INR',
      'timeout': 300,
      'prefill': {
        if (userEmail.isNotEmpty) 'email': userEmail,
        if (userName.isNotEmpty) 'name': userName,
      },
      'theme': {
        'color': '#8B5CF6',
      },
      'retry': {
        'enabled': true,
        'max_count': 3,
      },
    };

    _razorpay.open(options);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final plan = _activePaymentPlan;
    final orderId = (response.orderId != null && response.orderId!.isNotEmpty)
        ? response.orderId!
        : (_activeCheckoutOrder?.orderId ?? '');

    if (!mounted) return;

    // Show verification progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            margin: const EdgeInsets.symmetric(horizontal: 36),
            decoration: BoxDecoration(
              color: const Color(0xFF0A222E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF201338),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
                    ),
                  ),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFFB366FF),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Verifying Payment',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Activating your subscription on the server...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF8FA7B2),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final verifyRequest = VerifyPaymentRequest(
        razorpayOrderId: orderId,
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
      );

      await _remoteDataSource.verifyPayment(
        request: verifyRequest,
        endpoint: _plansResponse.verifyEndpoint,
      );

      if (mounted) {
        // Pop the verification loader
        Navigator.of(context, rootNavigator: true).pop();

        // Immediately update the plan badge so it shows when navigating back
        if (plan != null) {
          context.read<ProfileProvider>().setActivePlan(plan.plan);
          setState(() {
            _mySubscription = {
              'plan': plan.plan,
              'status': 'active',
            };
          });
        }

        // Refresh user profile & subscriptions in the background
        context.read<ProfileProvider>().fetchMyProfile();
        _fetchPlans();

        // Show celebration success modal
        _showSuccessDialog(plan);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        final errorMsg = _getReadableErrorMessage(
          e,
          defaultMessage:
              'Payment verification failed. If amount was deducted, please contact support.',
        );
        _showErrorSnackBar(errorMsg);
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    final message = response.message ?? 'Payment was cancelled or failed.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E293B),
        content: Row(
          children: [
            const Icon(Icons.cancel_outlined, color: Colors.amberAccent, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0F3647),
        content: Text(
          'External wallet selected: ${response.walletName ?? "Wallet"}',
          style: const TextStyle(color: Colors.white),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showSuccessDialog(SubscriptionPlan? plan) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF0A222E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: Color(0xFF22C55E), width: 2),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF133B2B),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF22C55E),
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "${plan?.label ?? 'Subscription'} Activated!",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Thank you for your payment. Your plan is now active with all premium features and verified badge.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF061821),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF133644),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSuccessLimitChip(
                        "${plan?.limits.likesPerDay ?? 200}",
                        "Likes/day",
                      ),
                      Container(width: 1, height: 28, color: const Color(0xFF133644)),
                      _buildSuccessLimitChip(
                        "${plan?.limits.commentsPerDay ?? 30}",
                        "Comments/day",
                      ),
                      Container(width: 1, height: 28, color: const Color(0xFF133644)),
                      _buildSuccessLimitChip(
                        "${plan?.limits.auditionApplicationsPerDay ?? 10}",
                        "Auditions/day",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (Navigator.canPop(context)) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.artistProfile);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Back to Profile",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessLimitChip(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            color: Color(0xFF38BDF8),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8FA7B2),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  void _showCheckoutSheet(SubscriptionPlan plan) {
    if (_isPlanDowngrade(plan)) {
      _showDowngradeDialog(plan);
      return;
    }
    if (_currentActivePlan != null &&
        _currentActivePlan!.toLowerCase() == plan.plan.toLowerCase()) {
      _showCurrentPlanInfoDialog(plan);
      return;
    }

    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (bottomSheetContext, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF0A222E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(
                  top: BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF201338),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
                            ),
                          ),
                          child: const Center(
                            child: FaIcon(
                              FontAwesomeIcons.crown,
                              color: Color(0xFFB366FF),
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _getPlanSubtitle(plan.plan),
                              style: const TextStyle(
                                color: Color(0xFF8FA7B2),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${plan.amountRupees}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              plan.periodLabel,
                              style: const TextStyle(
                                color: Color(0xFF38BDF8),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Color(0xFF153B4B)),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Icon(Icons.verified_user_outlined,
                            color: Color(0xFF38BDF8), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Instant Activation & Verified Badge',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.security, color: Color(0xFF22C55E), size: 18),
                        SizedBox(width: 8),
                        Text(
                          '256-bit Encrypted Checkout with Razorpay',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              setSheetState(() {
                                isSubmitting = true;
                              });
                              try {
                                await _startRazorpayCheckout(
                                  plan,
                                  onBeforeOpen: () {
                                    Navigator.pop(ctx);
                                  },
                                );
                              } catch (e) {
                                if (ctx.mounted) {
                                  Navigator.pop(ctx);
                                }
                                if (!mounted) return;

                                if (_isDowngradeError(e) ||
                                    _isPlanDowngrade(plan)) {
                                  _showDowngradeDialog(plan);
                                } else {
                                  final errorMsg = _getReadableErrorMessage(
                                    e,
                                    defaultMessage:
                                        'Checkout could not be initiated. Please try again.',
                                  );
                                  _showErrorSnackBar(errorMsg);
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            const Color(0xFF8B5CF6).withValues(alpha: 0.6),
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                        shadowColor:
                            const Color(0xFF8B5CF6).withValues(alpha: 0.5),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Proceed to Pay  ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  '₹${plan.amountRupees}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.arrow_forward_rounded, size: 18),
                              ],
                            ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getPlanSubtitle(String planKey) {
    if (planKey.toLowerCase().contains('max')) {
      return "For serious creators & professionals\nwho want more.";
    }
    return "Perfect for growing your presence\nand getting noticed.";
  }

  @override
  Widget build(BuildContext context) {
    // Watch ProfileProvider to instantly reflect subscription state changes
    context.watch<ProfileProvider>();

    final proPlan = _getPlan('pro') ??
        _plansResponse.plans.firstOrNull ??
        PaymentPlansResponse.defaultPlans().plans[0];

    final proMaxPlan = _getPlan('pro_max') ??
        (_plansResponse.plans.length > 1
            ? _plansResponse.plans[1]
            : PaymentPlansResponse.defaultPlans().plans[1]);

    return Scaffold(
      backgroundColor: const Color(0xFF071922),
      body:
      AppBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildTopAppBar(context),
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFF38BDF8),
                  backgroundColor: const Color(0xFF0F3647),
                  onRefresh: _fetchPlans,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        _buildHeroSection(),
                        const SizedBox(height: 26),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Choose Your Plan",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.2,
                              ),
                            ),
                            if (_isLoading)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF38BDF8),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ..._plansResponse.plans.map((plan) {
                          final isSelected = _selectedPlan == plan.plan;
                          final isRecommended =
                              _plansResponse.recommendedPlan == plan.plan;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildPlanCard(
                              plan: plan,
                              isSelected: isSelected,
                              isRecommended: isRecommended,
                            ),
                          );
                        }),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Plan Benefits & Limits",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.2,
                              ),
                            ),

                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildWhatYouGetSection(proPlan, proMaxPlan),
                        const SizedBox(height: 24),
                        _buildSecurePaymentFooter(),
                        const SizedBox(height: 110), // Bottom navbar offset
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(LucideIcons.chevronLeft, color: Colors.white, size: 24),
            onPressed: () {
              if (Navigator.canPop(context)) {
                context.pop();
              } else {
                context.go(AppRoutes.artistProfile);
              }
            },
          ),
          const Text(
            "Subscription",
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 48), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Minimalist royal crown badge
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF22143D),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF5A2A94),
              width: 1.2,
            ),
          ),
          child: const Center(
            child: FaIcon(
              FontAwesomeIcons.crown,
              color: Color(0xFFB066FE),
              size: 17,
            ),
          ),
        ),
        const SizedBox(height: 14),

        const Text(
          "Unlock Your",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.4,
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [
                Color(0xFF8B5CF6),
                Color(0xFFA855F7),
                Color(0xFFC084FC),
              ],
            ).createShader(bounds);
          },
          child: const Text(
            "Full Potential",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Get more visibility, connect with more people\nand take your talent to the next level.",
          style: TextStyle(
            color: Color(0xFF8FA7B2),
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required SubscriptionPlan plan,
    required bool isSelected,
    required bool isRecommended,
  }) {
    final subtitle = _getPlanSubtitle(plan.plan);
    final isCurrentPlan = _currentActivePlan != null &&
        _currentActivePlan!.toLowerCase() == plan.plan.toLowerCase();
    final isDowngrade = _isPlanDowngrade(plan);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = plan.plan;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: const Color(0xFF071E28).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isCurrentPlan
                ? const Color(0xFF22C55E)
                : (isSelected
                    ? const Color(0xFF8B5CF6)
                    : const Color(0xFF133644)),
            width: (isCurrentPlan || isSelected) ? 1.5 : 1.2,
          ),
          boxShadow: isCurrentPlan
              ? [
                  BoxShadow(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.25),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ]
              : (isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                        blurRadius: 18,
                        spreadRadius: 1,
                      ),
                    ]
                  : null),
        ),
        child: Stack(
          children: [
            // Top-right badge: "Current Plan" or "Recommended"
            if (isCurrentPlan || isRecommended)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCurrentPlan
                        ? const Color(0xFF22C55E)
                        : const Color(0xFF8B5CF6),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    isCurrentPlan ? "Current Plan" : "Recommended",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isCurrentPlan || isRecommended)
                          const SizedBox(height: 2),
                        Text(
                          plan.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              "₹${plan.amountRupees}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              " ${plan.periodLabel}",
                              style: const TextStyle(
                                color: Color(0xFF8FA7B2),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Color(0xFF8FA7B2),
                            fontSize: 11.5,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPlan = plan.plan;
                      });
                      if (isCurrentPlan) {
                        _showCurrentPlanInfoDialog(plan);
                      } else if (isDowngrade) {
                        _showDowngradeDialog(plan);
                      } else {
                        _showCheckoutSheet(plan);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: isCurrentPlan
                            ? const LinearGradient(
                                colors: [
                                  Color(0xFF16A34A),
                                  Color(0xFF15803D),
                                ],
                              )
                            : (isDowngrade
                                ? null
                                : (isSelected
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF8B5CF6),
                                          Color(0xFF6D28D9),
                                        ],
                                      )
                                    : null)),
                        color: isCurrentPlan
                            ? null
                            : (isDowngrade
                                ? const Color(0xFF0F2633)
                                : (isSelected ? null : const Color(0xFF0D2531))),
                        borderRadius: BorderRadius.circular(22),
                        border: isCurrentPlan
                            ? null
                            : Border.all(
                                color: isDowngrade
                                    ? const Color(0xFF1B3D4F)
                                    : (isSelected
                                        ? const Color(0xFF8B5CF6)
                                        : const Color(0xFF27586D)),
                                width: 1.2,
                              ),
                        boxShadow: isCurrentPlan
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF22C55E)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 10,
                                ),
                              ]
                            : (isDowngrade
                                ? null
                                : (isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF8B5CF6)
                                              .withValues(alpha: 0.4),
                                          blurRadius: 10,
                                        ),
                                      ]
                                    : null)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isCurrentPlan
                                ? "Active"
                                : (isDowngrade ? "Lower Tier" : "Subscribe"),
                            style: TextStyle(
                              color: isDowngrade
                                  ? const Color(0xFF8FA7B2)
                                  : Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Icon(
                            isCurrentPlan
                                ? Icons.check_circle_rounded
                                : (isDowngrade
                                    ? Icons.info_outline_rounded
                                    : Icons.arrow_forward_rounded),
                            color: isDowngrade
                                ? const Color(0xFF8FA7B2)
                                : Colors.white,
                            size: 15,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatYouGetSection(
      SubscriptionPlan proPlan, SubscriptionPlan proMaxPlan) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF071E28).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF153B4B),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF0B2836),
              borderRadius: BorderRadius.vertical(top: Radius.circular(19)),
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFF153B4B),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 5,
                  child: Text(
                    "BENEFIT",
                    style: TextStyle(
                      color: Color(0xFF8FA7B2),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                          width: 0.8,
                        ),
                      ),
                      child: const Text(
                        "PRO",
                        style: TextStyle(
                          color: Color(0xFFC084FC),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE11D48), Color(0xFF9333EA)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFE11D48).withValues(alpha: 0.35),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.crown,
                            color: Color(0xFFFDE047),
                            size: 8.5,
                          ),
                          SizedBox(width: 3.5),
                          Text(
                            "PRO MAX",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Rows
          _buildComparisonRow(
            icon: Icons.movie_creation_outlined,
            title: "Auditions",
            subtitle: "Daily casting apply",
            proValue: "${proPlan.limits.auditionApplicationsPerDay}",
            proMaxValue: "${proMaxPlan.limits.auditionApplicationsPerDay}",
            isHighlight: true,
          ),
          _buildComparisonRow(
            icon: Icons.chat_bubble_outline_rounded,
            title: "Messages",
            subtitle: "Connect with directors",
            proValue: "${proPlan.limits.messagesPerDay}",
            proMaxValue: "${proMaxPlan.limits.messagesPerDay}",
          ),
          _buildComparisonRow(
            icon: Icons.visibility_outlined,
            title: "Profile Views",
            subtitle: "Explore talents",
            proValue: "${proPlan.limits.profileViewsPerDay}",
            proMaxValue: "${proMaxPlan.limits.profileViewsPerDay}",
          ),
          _buildComparisonRow(
            icon: Icons.swap_vert_rounded,
            title: "Profile Scrolls",
            subtitle: "Daily feed browsing",
            proValue: "${proPlan.limits.profileScrollsPerDay}",
            proMaxValue: "${proMaxPlan.limits.profileScrollsPerDay}",
          ),
          _buildComparisonRow(
            icon: Icons.favorite_border_rounded,
            title: "Likes per day",
            subtitle: "Daily appreciation",
            proValue: "${proPlan.limits.likesPerDay}",
            proMaxValue: "${proMaxPlan.limits.likesPerDay}",
          ),
          _buildComparisonRow(
            icon: Icons.forum_outlined,
            title: "Comments",
            subtitle: "Community interactions",
            proValue: "${proPlan.limits.commentsPerDay}",
            proMaxValue: "${proMaxPlan.limits.commentsPerDay}",
          ),
          _buildCustomComparisonRow(
            icon: Icons.verified_user_outlined,
            title: "Verified Badge",
            subtitle: "Badge on your profile",
            proContent: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded,
                    color: Color(0xFF22C55E), size: 14),
                SizedBox(width: 3),
                Text(
                  "Included",
                  style: TextStyle(
                    color: Color(0xFF4ADE80),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            proMaxContent: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(
                  FontAwesomeIcons.crown,
                  color: Color(0xFFFDE047),
                  size: 11,
                ),
                SizedBox(width: 4),
                Text(
                  "VIP Crown",
                  style: TextStyle(
                    color: Color(0xFFFDE047),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            isLast: true,
          ),

          // Bottom tip callout
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFF0F3140).withValues(alpha: 0.5),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(19)),
            ),
            child: const Row(
              children: [
                Icon(Icons.auto_awesome, color: Color(0xFF38BDF8), size: 15),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Pro Max unlocks up to 10x higher daily limits & VIP exposure.",
                    style: TextStyle(
                      color: Color(0xFF8FA7B2),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String proValue,
    required String proMaxValue,
    bool isHighlight = false,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: isHighlight
            ? const Color(0xFF0D2836).withValues(alpha: 0.4)
            : Colors.transparent,
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(
                  color: Color(0xFF113240),
                  width: 0.8,
                ),
              ),
      ),
      child: Row(
        children: [
          // Icon + Titles
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E2836),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: const Color(0xFF1B4E63),
                      width: 0.8,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF38BDF8),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 1.5),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF7E97A4),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Pro Value
          Expanded(
            flex: 3,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF09202C),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF163C4D),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      proValue,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "/day",
                      style: TextStyle(
                        color: Color(0xFF7E97A4),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // const SizedBox(width: 4),

          // Pro Max Value (Highlighted purple gradient/border)
          Expanded(
            flex: 3,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1333),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
                    width: 0.9,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      proMaxValue,
                      style: const TextStyle(
                        color: Color(0xFFDDD6FE),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      "/day",
                      style: TextStyle(
                        color: Color(0xFFC084FC),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomComparisonRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget proContent,
    required Widget proMaxContent,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(
                  color: Color(0xFF113240),
                  width: 0.8,
                ),
              ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E2836),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: const Color(0xFF1B4E63),
                      width: 0.8,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF38BDF8),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 1.5),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF7E97A4),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(child: proContent),
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: 3,
            child: Center(child: proMaxContent),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurePaymentFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF061821).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF133644),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFF0E2836),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: Color(0xFF38BDF8),
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Secure Payment",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "Powered by Razorpay",
                style: TextStyle(
                  color: Color(0xFF7E97A4),
                  fontSize: 9.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              _buildVisaBadge(),
              const SizedBox(width: 8),
              _buildMastercardBadge(),
              const SizedBox(width: 8),
              _buildUpiBadge(),
              const SizedBox(width: 8),
              _buildGPayBadge(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisaBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF0A2E70),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        "VISA",
        style: TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMastercardBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(4),
      ),
      child: SizedBox(
        width: 18,
        height: 12,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 1,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEB001B),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 1,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF79E1B).withValues(alpha: 0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpiBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white24, width: 0.6),
      ),
      child: const Text(
        "UPI",
        style: TextStyle(
          color: Colors.white,
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildGPayBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF4285F4),
            ),
          ),
          const SizedBox(width: 2),
          const Text(
            "Pay",
            style: TextStyle(
              color: Color(0xFF3C4043),
              fontSize: 8,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
