import 'package:easypharma_flutter/core/constants/api_constants.dart';
import 'package:easypharma_flutter/core/services/api_service.dart';

class PaymentRepository {
  final ApiService _apiService;

  PaymentRepository(this._apiService);

  Future<Map<String, dynamic>> processPayment({
    required String orderId,
    required String method, // 'ORANGE_MONEY', 'MTN_MOMO'
    required double amount,
    required String phoneNumber,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.processPayment,
        data: {
          'orderId': orderId,
          'method': method,
          'amount': amount,
          'phoneNumber': phoneNumber,
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to process payment: $e');
    }
  }

  Future<Map<String, dynamic>> getPaymentReceipt(String paymentId) async {
    try {
      final response = await _apiService.get(
        ApiConstants.paymentReceipt(paymentId),
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to get receipt: $e');
    }
  }

  Future<Map<String, dynamic>> fetchPaymentByOrder(String orderId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.payments}/by-order/$orderId',
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch payment: $e');
    }
  }
}
