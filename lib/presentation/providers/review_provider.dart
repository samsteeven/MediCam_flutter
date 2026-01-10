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
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.submitReview({
        'pharmacyId': pharmacyId,
        'rating': rating,
        'comment': comment,
      });
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
