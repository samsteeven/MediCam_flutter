import 'package:flutter/material.dart';
import 'package:easypharma_flutter/data/models/delivery_model.dart';
import 'package:easypharma_flutter/data/repositories/delivery_repository.dart';

class DeliveryProvider with ChangeNotifier {
  final DeliveryRepository _repository;

  DeliveryProvider(this._repository);

  List<Delivery> _allDeliveries = [];
  List<Delivery> _ongoingDeliveries = [];
  DeliveryStats? _stats;
  bool _isLoading = false;
  String? _error;

  List<Delivery> get allDeliveries => _allDeliveries;
  List<Delivery> get ongoingDeliveries => _ongoingDeliveries;
  DeliveryStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAllDeliveries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allDeliveries = await _repository.getMyDeliveries();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOngoingDeliveries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _ongoingDeliveries = await _repository.getOngoingDeliveries();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStats() async {
    try {
      _stats = await _repository.getMyStats();
      notifyListeners();
    } catch (e) {
      print('Error fetching stats: $e');
    }
  }

  Future<void> updateDeliveryStatus(
    String deliveryId,
    DeliveryStatus status,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _repository.updateStatus(deliveryId, status.name);

      // Update in lists
      final allIndex = _allDeliveries.indexWhere((d) => d.id == deliveryId);
      if (allIndex != -1) {
        _allDeliveries[allIndex] = updated;
      }

      final ongoingIndex = _ongoingDeliveries.indexWhere(
        (d) => d.id == deliveryId,
      );
      if (ongoingIndex != -1) {
        if (status == DeliveryStatus.DELIVERED ||
            status == DeliveryStatus.CANCELLED) {
          _ongoingDeliveries.removeAt(ongoingIndex);
        } else {
          _ongoingDeliveries[ongoingIndex] = updated;
        }
      } else if (status != DeliveryStatus.DELIVERED &&
          status != DeliveryStatus.CANCELLED) {
        _ongoingDeliveries.add(updated);
      }

      await fetchStats(); // Refresh stats
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitProof(String deliveryId, String proofUrl) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _repository.submitProof(deliveryId, proofUrl);

      final allIndex = _allDeliveries.indexWhere((d) => d.id == deliveryId);
      if (allIndex != -1) {
        _allDeliveries[allIndex] = updated;
      }

      final ongoingIndex = _ongoingDeliveries.indexWhere(
        (d) => d.id == deliveryId,
      );
      if (ongoingIndex != -1) {
        _ongoingDeliveries[ongoingIndex] = updated;
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> assignDelivery(String orderId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.assignDelivery(orderId);
      await fetchOngoingDeliveries();
      await fetchStats();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
