import 'package:location/location.dart';

class LocationService {
  final Location _location = Location();

  Future<LocationData?> getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // 1. Vérifier si le service est activé
    try {
      serviceEnabled = await _location.serviceEnabled();
    } catch (e) {
      // En cas d'erreur (ex: simulateur), on suppose désactivé pour forcer la demande ou on log
      serviceEnabled = false;
    }

    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        throw LocationServiceDisabledException();
      }
    }

    // 2. Vérifier les permissions
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted &&
          permissionGranted != PermissionStatus.grantedLimited) {
        throw LocationPermissionDeniedException();
      }
    }

    // 3. Cas refusé définitivement
    if (permissionGranted == PermissionStatus.deniedForever) {
      throw LocationPermissionPermanentlyDeniedException();
    }

    return await _location.getLocation();
  }
}

class LocationPermissionDeniedException implements Exception {
  final String message = 'Permission de localisation refusée';
}

class LocationPermissionPermanentlyDeniedException implements Exception {
  final String message = 'Permission de localisation refusée définitivement';
}

class LocationServiceDisabledException implements Exception {
  final String message = 'Le service de localisation est désactivé';
}
