import 'package:easypharma_flutter/core/constants/api_constants.dart';
import 'package:easypharma_flutter/core/services/api_service.dart';
import 'package:easypharma_flutter/data/models/review_model.dart';
import 'package:flutter/material.dart';

class ReviewRepository {
  final ApiService _apiService;

  ReviewRepository(this._apiService);

  /// Lister les avis d'une pharmacie
  /// GET /api/v1/reviews/pharmacy/{pharmacyId}
  Future<List<Review>> fetchPharmacyReviews(String pharmacyId) async {
    try {
      final response = await _apiService.get(
        ApiConstants.pharmacyReviews(pharmacyId),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data is List ? response.data : response.data['data'] ?? [];
        return data
            .map((json) => Review.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Erreur de chargement des avis: $e');
    }
  }

  /// Laisser un avis
  /// POST /api/v1/reviews
  Future<void> submitReview(Map<String, dynamic> reviewData) async {
    try {
      debugPrint('ReviewRepository.submitReview - payload: $reviewData');
      await _apiService.post(ApiConstants.reviews, data: reviewData);
      debugPrint('ReviewRepository.submitReview - success');
    } catch (e) {
      debugPrint('ReviewRepository.submitReview - error: $e');

      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('duplicate') ||
          errorStr.contains('dupliq') ||
          errorStr.contains('uksbkc') ||
          errorStr.contains('alread')) {
        throw Exception('Vous avez déjà soumis un avis pour cette commande.');
      }
      rethrow;
    }
  }

  /// Modérer un avis (Admin)
  /// PATCH /api/v1/reviews/{id}/status
  Future<void> moderateReview(String reviewId, String status) async {
    try {
      await _apiService.patch(
        ApiConstants.moderateReview(reviewId),
        data: {'status': status},
      );
    } catch (e) {
      throw Exception('Erreur moderation: $e');
    }
  }

  /// Supprimer un avis (utilisateur propriétaire)
  Future<void> deleteReview(String reviewId) async {
    try {
      await _apiService.delete(ApiConstants.reviewById(reviewId));
    } catch (e) {
      throw Exception('Erreur suppression: $e');
    }
  }
}
