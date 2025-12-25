import 'package:dio/dio.dart';
import 'package:easypharma_flutter/data/models/pharmacy_model.dart';
import 'package:easypharma_flutter/core/constants/api_constants.dart';

class PharmaciesRepository {
  final Dio _dio;

  PharmaciesRepository(this._dio);

  /// Lister toutes les pharmacies
  /// GET /api/v1/pharmacies
  Future<List<Pharmacy>> getAllPharmacies() async {
    try {
      final response = await _dio.get(ApiConstants.pharmacies);

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

  /// Récupérer une pharmacie par ID
  /// GET /api/v1/pharmacies/{id}
  Future<Pharmacy> getPharmacyById(String pharmacyId) async {
    try {
      final response = await _dio.get('${ApiConstants.pharmacies}/$pharmacyId');

      if (response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : response.data['data'];
        return Pharmacy.fromJson(data as Map<String, dynamic>);
      }
      throw Exception(
        'Erreur lors de la récupération de la pharmacie: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Récupérer une pharmacie par numéro de licence
  /// GET /api/v1/pharmacies/by-license/{licenseNumber}
  Future<Pharmacy> getPharmacyByLicense(String licenseNumber) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.pharmaciesByLicense}/$licenseNumber',
      );

      if (response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : response.data['data'];
        return Pharmacy.fromJson(data as Map<String, dynamic>);
      }
      throw Exception(
        'Erreur lors de la récupération de la pharmacie: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

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

  /// Rechercher les pharmacies par nom
  /// GET /api/v1/pharmacies/search/by-name?name={name}
  Future<List<Pharmacy>> searchByName(String name) async {
    try {
      final response = await _dio.get(
        ApiConstants.searchPharmaciesByName,
        queryParameters: {'name': name},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data is List ? response.data : response.data['data'] ?? [];
        return List<Pharmacy>.from(
          data.map((json) => Pharmacy.fromJson(json as Map<String, dynamic>)),
        );
      }
      throw Exception('Erreur lors de la recherche: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Rechercher les pharmacies par ville
  /// GET /api/v1/pharmacies/search/by-city?city={city}
  Future<List<Pharmacy>> searchByCity(String city) async {
    try {
      final response = await _dio.get(
        ApiConstants.searchPharmaciesByCity,
        queryParameters: {'city': city},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data is List ? response.data : response.data['data'] ?? [];
        return List<Pharmacy>.from(
          data.map((json) => Pharmacy.fromJson(json as Map<String, dynamic>)),
        );
      }
      throw Exception('Erreur lors de la recherche: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Rechercher les pharmacies par statut
  /// GET /api/v1/pharmacies/search/by-status?status={status}
  Future<List<Pharmacy>> searchByStatus(String status) async {
    try {
      final response = await _dio.get(
        ApiConstants.searchPharmaciesByStatus,
        queryParameters: {'status': status},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data is List ? response.data : response.data['data'] ?? [];
        return List<Pharmacy>.from(
          data.map((json) => Pharmacy.fromJson(json as Map<String, dynamic>)),
        );
      }
      throw Exception('Erreur lors de la recherche: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Récupérer les pharmacies approuvées par ville
  /// GET /api/v1/pharmacies/approved/by-city?city={city}
  Future<List<Pharmacy>> getApprovedByCity(String city) async {
    try {
      final response = await _dio.get(
        ApiConstants.approvedPharmaciesByCity,
        queryParameters: {'city': city},
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

  /// Créer une nouvelle pharmacie
  /// POST /api/v1/pharmacies
  Future<Pharmacy> createPharmacy(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiConstants.pharmacies, data: data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final respData =
            response.data is Map ? response.data : response.data['data'];
        return Pharmacy.fromJson(respData as Map<String, dynamic>);
      }
      throw Exception('Erreur lors de la création: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Mettre à jour une pharmacie
  /// PUT /api/v1/pharmacies/{id}
  Future<Pharmacy> updatePharmacy(
    String pharmacyId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.pharmacies}/$pharmacyId',
        data: data,
      );

      if (response.statusCode == 200) {
        final respData =
            response.data is Map ? response.data : response.data['data'];
        return Pharmacy.fromJson(respData as Map<String, dynamic>);
      }
      throw Exception('Erreur lors de la mise à jour: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Changer le statut d'une pharmacie
  /// PATCH /api/v1/pharmacies/{id}/status
  Future<Pharmacy> changeStatus(String pharmacyId, String newStatus) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.pharmacies}/$pharmacyId/status',
        data: {'status': newStatus},
      );

      if (response.statusCode == 200) {
        final respData =
            response.data is Map ? response.data : response.data['data'];
        return Pharmacy.fromJson(respData as Map<String, dynamic>);
      }
      throw Exception(
        'Erreur lors de la mise à jour du statut: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Supprimer une pharmacie
  /// DELETE /api/v1/pharmacies/{id}
  Future<void> deletePharmacy(String pharmacyId) async {
    try {
      final response = await _dio.delete(
        '${ApiConstants.pharmacies}/$pharmacyId',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Erreur lors de la suppression: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }
}
