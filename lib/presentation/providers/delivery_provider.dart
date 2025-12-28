import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easypharma_flutter/data/models/delivery_model.dart';
import 'package:easypharma_flutter/data/repositories/delivery_repository.dart';
import 'package:easypharma_flutter/presentation/providers/location_provider.dart';

class DeliveryProvider extends ChangeNotifier {
  final DeliveryRepository _repository;
  final LocationProvider? _locationProvider; // Ajout pour GPS réel

  DeliveryProvider(this._repository, {LocationProvider? locationProvider})
    : _locationProvider = locationProvider;

  // Stats
  DeliveryStats _stats = DeliveryStats();
  DeliveryStats get stats => _stats;

  // Deliveries
  List<Delivery> _ongoingDeliveries = [];
  List<Delivery> get ongoingDeliveries => _ongoingDeliveries;

  List<Delivery> _allDeliveries = [];
  List<Delivery> get allDeliveries => _allDeliveries;

  // Loading & Error
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Tracking
  Timer? _trackingTimer;
  bool _isTracking = false;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> loadDashboardData() async {
    _setLoading(true);
    _setError(null);
    try {
      await Future.wait([fetchStats(), fetchOngoingDeliveries()]);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchStats() async {
    try {
      _stats = await _repository.getMyStats();
      notifyListeners();
    } catch (e) {
      print('Error fetching stats: $e');
      rethrow;
    }
  }

  Future<void> fetchOngoingDeliveries() async {
    try {
      _ongoingDeliveries = await _repository.getOngoingDeliveries();
      notifyListeners();
    } catch (e) {
      print('Error fetching ongoing deliveries: $e');
      rethrow;
    }
  }

  Future<void> fetchAllDeliveries() async {
    _setLoading(true);
    try {
      _allDeliveries = await _repository.getMyDeliveries();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> acceptDelivery(String deliveryId) async {
    _setLoading(true);
    try {
      await _repository.updateStatus(deliveryId, 'PICKED_UP');
      await fetchOngoingDeliveries(); // Refresh list
      // Start tracking if needed
      startLocationTracking(deliveryId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> completeDelivery(String deliveryId, String proofUrl) async {
    _setLoading(true);
    try {
      await _repository.submitProof(deliveryId, proofUrl);
      // Status update to DELIVERED effectively handled by proof submission usually, or explicit update
      await _repository.updateStatus(deliveryId, 'DELIVERED');
      stopLocationTracking();
      await fetchOngoingDeliveries();
      await fetchStats();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Simulation of location tracking
  void startLocationTracking(String deliveryId) {
    if (_isTracking) return;
    _isTracking = true;
    _trackingTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (!_isTracking) {
        timer.cancel();
        return;
      }

      try {
        if (_locationProvider != null) {
          await _locationProvider.ensureLocation();
          final location = _locationProvider.userLocation;
          if (location != null &&
              location.latitude != null &&
              location.longitude != null) {
            await _repository.updateLocation(
              deliveryId,
              location.latitude!,
              location.longitude!,
            );
            print(
              'Tracking position réelle pour $deliveryId: ${location.latitude}, ${location.longitude}',
            );
          }
        } else {
          print('Tracking simulé pour $deliveryId (pas de locationProvider)');
        }
      } catch (e) {
        print('Erreur tracking GPS: $e');
      }
    });
  }

  void stopLocationTracking() {
    _isTracking = false;
    _trackingTimer?.cancel();
    _trackingTimer = null;
  }

  @override
  void dispose() {
    stopLocationTracking();
    super.dispose();
  }
}
