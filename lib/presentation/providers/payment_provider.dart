import 'package:flutter/material.dart';
import 'package:easypharma_flutter/data/repositories/payment_repository.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  PaymentProvider(this._repository);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> processPayment({
    required String orderId,
    required String method,
    required double amount,
    required String phoneNumber,
    required Function(Map<String, dynamic> paymentData) onSuccess,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.processPayment(
        orderId: orderId,
        method: method,
        amount: amount,
        phoneNumber: phoneNumber,
      );

      _successMessage = 'Paiement effectué avec succès';
      // Pass the full result (payment data) to the callback
      onSuccess(result);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> getReceipt(String paymentId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _repository.getPaymentReceipt(paymentId);
      return data;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> fetchPaymentByOrder(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final data = await _repository.fetchPaymentByOrder(orderId);
      return data;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
