// presentation/providers/location_provider.dart
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import '../../core/services/location_service.dart';

class LocationProvider with ChangeNotifier {
  final LocationService _service = LocationService();
  LocationData? _userLocation;
  bool _isServiceEnabled = false;
  LocationData? get userLocation => _userLocation;

  String? _error;
  String? get error => _error;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Méthode pour s'assurer qu'on a la position avant un appel API
  Future<void> ensureLocation() async {
    if (_userLocation != null) return; // Déjà récupéré, on ne fait rien

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _service.getCurrentLocation().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Délai d\'attente dépassé pour la localisation.');
        },
      );

      if (data != null) {
        _userLocation = data;
        _isServiceEnabled = true;
        _error = null;
        debugPrint(
          "📍 Localisation récupérée : ${data.latitude}, ${data.longitude}",
        );
      } else {
        _error = "Impossible de récupérer la position (null).";
      }
    } on LocationServiceDisabledException {
      _error = 'Le service de localisation est désactivé.';
      _userLocation = null;
    } on LocationPermissionDeniedException {
      _error = 'Permission refusée. L\'application a besoin de votre position.';
      _userLocation = null;
    } on LocationPermissionPermanentlyDeniedException {
      _error =
          'Permission refusée définitivement. Veuillez l\'activer dans les paramètres.';
      _userLocation = null;
    } catch (e) {
      _error = 'Erreur position : $e';
      // ne pas forcément mettre à null si on avait une vieille position ?
      // Pour l'instant on reset pour forcer la cohérence
      _userLocation = null;
      debugPrint("❌ Location error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
