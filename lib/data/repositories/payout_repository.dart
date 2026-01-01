import 'package:dio/dio.dart';
import 'package:easypharma_flutter/core/constants/api_constants.dart';
import 'package:easypharma_flutter/data/models/payout_model.dart';

class PayoutRepository {
  final Dio _dio;

  PayoutRepository(this._dio);

  /// Historique des reversements d'une pharmacie
  /// GET /api/v1/payouts/pharmacy/{pharmacyId}
  Future<List<Payout>> fetchPharmacyPayouts(String pharmacyId) async {
    try {
      final response = await _dio.get(ApiConstants.pharmacyPayouts(pharmacyId));
      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data is List ? response.data : response.data['data'] ?? [];
        return data
            .map((json) => Payout.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Enregistrer un reversement
  /// POST /api/v1/payouts
  Future<void> createPayout(Map<String, dynamic> payoutData) async {
    try {
      await _dio.post(ApiConstants.payouts, data: payoutData);
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }
}
