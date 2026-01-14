import 'package:dio/dio.dart';
import 'package:easypharma_flutter/core/constants/api_constants.dart';
import 'package:easypharma_flutter/data/models/medication_model.dart';
import 'package:easypharma_flutter/data/models/pharmacy_model.dart';

class MedicationRepository {
  final Dio _dio;

  MedicationRepository(this._dio);

  /// Recherche de médicaments par nom et catégorie thérapeutique
  /// Utilise l'endpoint de recherche patient qui retourne des PharmacyMedication avec stocks
  Future<List<PharmacyMedication>> searchMedications({
    required String name,
    String? therapeuticClass,
    double? userLat,
    double? userLon,
    String sortBy = 'NEAREST',
    bool? requiresPrescription,
    double? minPrice,
    double? maxPrice,
    String? availability,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.patientSearch,
        queryParameters: {
          'query': name,
          'sortBy': sortBy,
          if (userLat != null) 'userLat': userLat,
          if (userLon != null) 'userLon': userLon,
          if (therapeuticClass != null) 'therapeuticClass': therapeuticClass,
          if (requiresPrescription != null)
            'requiresPrescription': requiresPrescription,
          if (minPrice != null) 'minPrice': minPrice,
          if (maxPrice != null) 'maxPrice': maxPrice,
          if (availability != null) 'availability': availability,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data is List ? response.data : response.data['data'] ?? [];

        return data
            .map(
              (json) =>
                  PharmacyMedication.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Obtenir les prix d'un médicament dans différentes pharmacies (triés par prix)
  /// Récupère toutes les pharmacies et cherche le médicament dans chacune
  Future<List<PharmacyMedication>> getPricesAcrossPharmacies({
    required String medicationId,
  }) async {
    try {
      // Récupérer toutes les pharmacies
      final pharmaciesResponse = await _dio.get(ApiConstants.pharmacies);
      if (pharmaciesResponse.statusCode != 200) {
        throw Exception('Erreur lors de la récupération des pharmacies');
      }

      final List<dynamic> pharmaciesData =
          pharmaciesResponse.data is List
              ? pharmaciesResponse.data
              : pharmaciesResponse.data['data'] ?? [];
      final List<Pharmacy> pharmacies = List<Pharmacy>.from(
        pharmaciesData.map(
          (json) => Pharmacy.fromJson(json as Map<String, dynamic>),
        ),
      );

      // Vérifier s'il y a des pharmacies
      if (pharmacies.isEmpty) {
        throw Exception('Aucune pharmacie disponible pour afficher les prix.');
      }

      // Collecter les prix du médicament dans chaque pharmacie
      final List<PharmacyMedication> priceResults = [];

      for (final pharmacy in pharmacies) {
        try {
          final medResponse = await _dio.get(
            ApiConstants.pharmacyMedications(pharmacy.id),
          );

          if (medResponse.statusCode == 200) {
            final List<dynamic> medData =
                medResponse.data is List
                    ? medResponse.data
                    : medResponse.data['data'] ?? [];

            for (final item in medData) {
              final pharmacyMed = PharmacyMedication.fromJson(
                item as Map<String, dynamic>,
              );
              if (pharmacyMed.medication.id == medicationId) {
                priceResults.add(pharmacyMed);
              }
            }
          }
        } catch (e) {
          print('Erreur pour pharmacy ${pharmacy.id}: $e');
        }
      }

      // Trier par prix croissant
      priceResults.sort((a, b) => a.price.compareTo(b.price));
      return priceResults;
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Obtenir les pharmacies les plus proches
  /// GET /api/v1/pharmacies/nearby?latitude={lat}&longitude={lon}&radiusKm={radius}
  Future<List<Pharmacy>> getNearbyPharmacies({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.nearbyPharmacies,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radiusKm': radiusKm,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data is List ? response.data : response.data['data'] ?? [];
        return List<Pharmacy>.from(
          data.map((json) => Pharmacy.fromJson(json as Map<String, dynamic>)),
        );
      }
      throw Exception(
        'Erreur lors de la récupération des pharmacies: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Filtrer les médicaments (Global Catalog)
  /// GET /api/v1/medications/filter
  Future<List<Medication>> filterMedications(
    Map<String, dynamic> filters,
  ) async {
    try {
      final response = await _dio.get(
        ApiConstants.filterMedications,
        queryParameters: filters,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data is List ? response.data : response.data['data'] ?? [];
        return data
            .map((json) => Medication.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Erreur lors du filtrage des médicaments: $e');
    }
  }

  /// Médicaments par classe thérapeutique (Global Catalog)
  /// GET /api/v1/medications/by-class/{therapeuticClass}
  Future<List<Medication>> getMedicationsByClass(
    String therapeuticClass,
  ) async {
    try {
      final response = await _dio.get(
        ApiConstants.medicationsByClass(therapeuticClass),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data is List ? response.data : response.data['data'] ?? [];
        return data
            .map((json) => Medication.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Erreur lors de la récupération par classe: $e');
    }
  }

  /// Médicaments nécessitant ordonnance (Global Catalog)
  /// GET /api/v1/medications/prescription-required
  Future<List<Medication>> getPrescriptionRequiredMedications() async {
    try {
      final response = await _dio.get(ApiConstants.prescriptionRequired);
      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data is List ? response.data : response.data['data'] ?? [];
        return data
            .map((json) => Medication.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération des médicaments sur ordonnance: $e',
      );
    }
  }

  /// Top Médicaments Vendus (Admin)
  Future<List<Medication>> getTopSoldMedications() async {
    try {
      final response = await _dio.get(ApiConstants.adminTopSold);
      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data is List ? response.data : response.data['data'] ?? [];
        return data
            .map((json) => Medication.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Obtenir les médicaments d'une pharmacie spécifique
  /// GET /api/v1/pharmacies/{pharmacyId}/medications?name={name}
  Future<List<PharmacyMedication>> getPharmacyMedications({
    required String pharmacyId,
    String? name,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (name != null) {
        queryParams['name'] = name;
      }

      final response = await _dio.get(
        ApiConstants.pharmacyMedications(pharmacyId),
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data is List ? response.data : response.data['data'] ?? [];
        return List<PharmacyMedication>.from(
          data.map(
            (json) => PharmacyMedication.fromJson(json as Map<String, dynamic>),
          ),
        );
      }
      throw Exception(
        'Erreur lors de la récupération des médicaments: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }
}
