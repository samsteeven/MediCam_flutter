// presentation/providers/location_provider.dart
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geo;
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
        const Duration(seconds: 30),
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

  // Nouvelle méthode pour obtenir l'adresse et la ville
  Future<Map<String, String>?> getAddressFromLocation() async {
    await ensureLocation();
    if (_userLocation == null) return null;

    try {
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        _userLocation!.latitude!,
        _userLocation!.longitude!,
      );

      if (placemarks.isNotEmpty) {
        // On cherche le meilleur quartier dans tous les résultats
        String neighborhood = '';
        String city = '';

        for (var place in placemarks) {
          // 1. On cherche d'abord dans subLocality (quartier)
          if (place.subLocality != null &&
              place.subLocality!.isNotEmpty &&
              !place.subLocality!.contains('+')) {
            neighborhood = place.subLocality!;
            break;
          }
        }

        // 2. Si rien trouvé, on cherche dans thoroughfare (rue/zone) ou name
        if (neighborhood.isEmpty) {
          for (var place in placemarks) {
            if (place.thoroughfare != null &&
                place.thoroughfare!.isNotEmpty &&
                !place.thoroughfare!.contains('+')) {
              neighborhood = place.thoroughfare!;
              break;
            }
            if (place.name != null &&
                place.name!.isNotEmpty &&
                !place.name!.contains('+')) {
              neighborhood = place.name!;
              break;
            }
          }
        }

        // Récupération de la ville
        geo.Placemark bestPlace = placemarks[0];
        city = bestPlace.locality ?? bestPlace.subAdministrativeArea ?? '';

        return {
          'address':
              neighborhood.isEmpty ? 'Quartier non détecté' : neighborhood,
          'city': city,
        };
      }
    } catch (e) {
      debugPrint(" Geocoding error: $e");
      _error = "Impossible de récupérer l'adresse depuis la position.";
      notifyListeners();
    }
    return null;
  }
}
