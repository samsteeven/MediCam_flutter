import 'package:dio/dio.dart';
import 'package:easypharma_flutter/core/constants/api_constants.dart';
import 'package:easypharma_flutter/data/models/review_model.dart';

class ReviewRepository {
  final Dio _dio;

  ReviewRepository(this._dio);

  /// Lister les avis d'une pharmacie
  /// GET /api/v1/reviews/pharmacy/{pharmacyId}
  Future<List<Review>> fetchPharmacyReviews(String pharmacyId) async {
    try {
      final response = await _dio.get(ApiConstants.pharmacyReviews(pharmacyId));
      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data is List ? response.data : response.data['data'] ?? [];
        return data
            .map((json) => Review.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Laisser un avis
  /// POST /api/v1/reviews
  Future<void> submitReview(Map<String, dynamic> reviewData) async {
    try {
      await _dio.post(ApiConstants.reviews, data: reviewData);
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Modérer un avis (Admin)
  /// PATCH /api/v1/reviews/{id}/status
  Future<void> moderateReview(String reviewId, String status) async {
    try {
      await _dio.patch(
        ApiConstants.moderateReview(reviewId),
        data: {'status': status},
      );
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }
}
