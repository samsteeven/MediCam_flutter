import 'package:flutter/foundation.dart';
import 'package:easypharma_flutter/data/models/review_model.dart';
import 'package:easypharma_flutter/data/repositories/review_repository.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewRepository _repository;

  List<Review> _pharmacyReviews = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Review> get pharmacyReviews => _pharmacyReviews;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ReviewProvider(this._repository);

  Future<void> fetchPharmacyReviews(String pharmacyId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pharmacyReviews = await _repository.fetchPharmacyReviews(pharmacyId);
    } catch (e) {
      _errorMessage = e.toString();
      _pharmacyReviews = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitReview({
    required String pharmacyId,
    required int rating,
    required String comment,
    String? orderId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final payload = <String, dynamic>{
        'pharmacyId': pharmacyId,
        'pharmacyRating': rating,
        'pharmacyComment': comment,
      };
      if (orderId != null && orderId.isNotEmpty) payload['orderId'] = orderId;

      await _repository.submitReview(payload);

      // Refresh reviews so the user sees everyone else's feedback.
      // Backend returns APPROVED reviews + user's own review (even if PENDING)
      await fetchPharmacyReviews(pharmacyId);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteReview(String reviewId, String pharmacyId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteReview(reviewId);
      // Refresh reviews after deletion
      await fetchPharmacyReviews(pharmacyId);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
