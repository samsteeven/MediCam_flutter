import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:easypharma_flutter/data/models/review_model.dart';
import 'package:easypharma_flutter/data/repositories/prescription_repository.dart';

class PrescriptionProvider extends ChangeNotifier {
  final PrescriptionRepository _repository;

  List<Prescription> _myPrescriptions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Prescription> get myPrescriptions => _myPrescriptions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  PrescriptionProvider(this._repository);

  Future<void> fetchMyPrescriptions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _myPrescriptions = await _repository.fetchMyPrescriptions();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadPrescription(FormData formData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.uploadPrescription(formData);
      await fetchMyPrescriptions();
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
