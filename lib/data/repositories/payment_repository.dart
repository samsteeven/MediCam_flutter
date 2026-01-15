import 'package:dio/dio.dart';
import 'package:easypharma_flutter/core/constants/api_constants.dart';
import 'package:easypharma_flutter/data/models/payment_model.dart';

class PaymentRepository {
  final Dio _dio;

  PaymentRepository(this._dio);

  /// Effectuer un paiement
  /// POST /api/v1/payments
  Future<Payment> processPayment(Map<String, dynamic> paymentData) async {
    try {
      final response = await _dio.post(
        ApiConstants.processPayment,
        data: paymentData,
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : response.data['data'];
        return Payment.fromJson(data as Map<String, dynamic>);
      }
      throw Exception('Erreur lors du paiement: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Récupérer le paiement d'une commande
  /// GET /api/v1/payments/order/{orderId}
  Future<Payment?> getPaymentByOrder(String orderId) async {
    try {
      final response = await _dio.get(ApiConstants.orderPayment(orderId));
      if (response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : response.data['data'];
        if (data == null) return null;
        return Payment.fromJson(data as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw Exception('Erreur réseau: ${e.message}');
    }
  }
}
