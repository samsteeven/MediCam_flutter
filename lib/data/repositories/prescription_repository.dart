import 'package:dio/dio.dart';
import 'package:easypharma_flutter/core/constants/api_constants.dart';
import 'package:easypharma_flutter/data/models/review_model.dart'; // Prescription est dans review_model.dart

class PrescriptionRepository {
  final Dio _dio;

  PrescriptionRepository(this._dio);

  /// Mes ordonnances
  /// GET /api/v1/prescriptions/my-prescriptions
  Future<List<Prescription>> fetchMyPrescriptions() async {
    try {
      final response = await _dio.get(ApiConstants.myPrescriptions);
      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data is List ? response.data : response.data['data'] ?? [];
        return data
            .map((json) => Prescription.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Téléverser une ordonnance
  /// POST /api/v1/prescriptions
  Future<void> uploadPrescription(FormData formData) async {
    try {
      await _dio.post(ApiConstants.prescriptions, data: formData);
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }
}
