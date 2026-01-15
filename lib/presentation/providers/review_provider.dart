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

  Future<void> fetchPharmacyReviews(String pharmacyId, {String? status}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pharmacyReviews = await _repository.fetchPharmacyReviews(
        pharmacyId,
        status: status,
      );
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

      // Refresh approved reviews so the user sees everyone else's feedback.
      // Newly created review will be PENDING, so it might not show up
      // in the APPROVED list immediately unless moderated.
      await fetchPharmacyReviews(pharmacyId, status: 'APPROVED');
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
      // Refresh approved list after deletion
      await fetchPharmacyReviews(pharmacyId, status: 'APPROVED');
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
