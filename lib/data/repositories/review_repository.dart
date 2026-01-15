import 'package:dio/dio.dart';
import 'package:easypharma_flutter/core/constants/api_constants.dart';
import 'package:easypharma_flutter/data/models/review_model.dart';
import 'package:flutter/material.dart';

class ReviewRepository {
  final Dio _dio;

  ReviewRepository(this._dio);

  /// Lister les avis d'une pharmacie
  /// GET /api/v1/reviews/pharmacy/{pharmacyId}
  Future<List<Review>> fetchPharmacyReviews(
    String pharmacyId, {
    String? status,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.pharmacyReviews(pharmacyId),
        queryParameters: status != null ? {'status': status} : null,
      );
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
      // Debug: log payload and server response to help diagnose missing reviews
      // Keep signature as Future<void> to avoid API changes across the app
      // Note: logs will appear in the app console (debugPrint)
      debugPrint('ReviewRepository.submitReview - payload: $reviewData');
      final response = await _dio.post(ApiConstants.reviews, data: reviewData);
      debugPrint(
        'ReviewRepository.submitReview - status: ${response.statusCode}',
      );
      debugPrint('ReviewRepository.submitReview - response: ${response.data}');
    } on DioException catch (e) {
      debugPrint('ReviewRepository.submitReview - error: ${e.message}');
      debugPrint(
        'ReviewRepository.submitReview - error response: ${e.response?.statusCode} ${e.response?.data}',
      );

      // Try to detect DB unique-constraint / duplicate-review errors and return a clear message
      final respData = e.response?.data;
      final respStr =
          respData != null
              ? respData.toString().toLowerCase()
              : (e.message?.toLowerCase() ?? '');
      if (respStr.contains('duplicate') ||
          respStr.contains('dupliq') ||
          respStr.contains('uksbkc')) {
        throw Exception('Vous avez déjà soumis un avis pour cette commande.');
      }

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

  /// Supprimer un avis (utilisateur propriétaire)
  Future<void> deleteReview(String reviewId) async {
    try {
      await _dio.delete(ApiConstants.reviewById(reviewId));
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }
}
