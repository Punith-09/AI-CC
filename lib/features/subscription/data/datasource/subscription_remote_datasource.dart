import '../../../../core/api/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/subscription_plan_model.dart';

class SubscriptionRemoteDataSource {
  final DioClient _dioClient;

  SubscriptionRemoteDataSource(this._dioClient);

  Future<PaymentPlansResponse> getPlans() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.paymentPlans);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : (response.data is Map
                ? Map<String, dynamic>.from(response.data as Map)
                : null);
        if (data != null) {
          return PaymentPlansResponse.fromJson(data);
        }
      }
      return PaymentPlansResponse.defaultPlans();
    } catch (e) {
      return PaymentPlansResponse.defaultPlans();
    }
  }

  Future<CheckoutOrderResponse> createCheckoutOrder({
    required String plan,
    String? endpoint,
  }) async {
    final path = (endpoint != null && endpoint.isNotEmpty)
        ? endpoint
        : ApiEndpoints.paymentCheckout;

    final response = await _dioClient.post(
      path,
      data: {'plan': plan},
    );

    if (response.data != null) {
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : Map<String, dynamic>.from(response.data as Map);
      return CheckoutOrderResponse.fromJson(data);
    }
    throw Exception('Failed to create Razorpay checkout order');
  }

  Future<VerifyPaymentResponse> verifyPayment({
    required VerifyPaymentRequest request,
    String? endpoint,
  }) async {
    final path = (endpoint != null && endpoint.isNotEmpty)
        ? endpoint
        : ApiEndpoints.paymentVerify;

    final response = await _dioClient.post(
      path,
      data: request.toJson(),
    );

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      return VerifyPaymentResponse.fromJson(response.data);
    }
    throw Exception('Failed to verify payment on server');
  }

  Future<Map<String, dynamic>?> getMySubscription() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.subscriptionsMe);
      if (response.data != null && response.data is Map) {
        return response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data as Map);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
