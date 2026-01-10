import 'package:dio/dio.dart';
import 'package:easypharma_flutter/data/models/pharmacy_model.dart';
import 'package:easypharma_flutter/core/constants/api_constants.dart';

class PharmacyInventoryRepository {
  final Dio _dio;

  PharmacyInventoryRepository(this._dio);

  /// Lister l'inventaire des médicaments d'une pharmacie
  /// GET /api/v1/pharmacies/{pharmacyId}/medications
  Future<List<PharmacyMedicationInventory>> getInventory(
    String pharmacyId,
  ) async {
    try {
      final response = await _dio.get(
        ApiConstants.pharmacyMedications(pharmacyId),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data is List ? response.data : response.data['data'] ?? [];
        return List<PharmacyMedicationInventory>.from(
          data.map(
            (json) => PharmacyMedicationInventory.fromJson(
              json as Map<String, dynamic>,
            ),
          ),
        );
      }
      throw Exception(
        'Erreur lors de la récupération de l\'inventaire: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Ajouter un médicament à l'inventaire
  /// POST /api/v1/pharmacies/{pharmacyId}/medications
  Future<PharmacyMedicationInventory> addMedication(
    String pharmacyId,
    String medicationId,
    double price,
    int stockQuantity,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.pharmacyMedications(pharmacyId),
        data: {
          'medicationId': medicationId,
          'price': price,
          'stockQuantity': stockQuantity,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : response.data['data'];
        return PharmacyMedicationInventory.fromJson(
          data as Map<String, dynamic>,
        );
      }
      throw Exception(
        'Erreur lors de l\'ajout du médicament: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Mettre à jour le stock d'un médicament
  /// PATCH /api/v1/pharmacies/{pharmacyId}/medications/{medicationId}/stock
  Future<PharmacyMedicationInventory> updateStock(
    String pharmacyId,
    String medicationId,
    int stockQuantity,
  ) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.pharmacyMedications(pharmacyId)}/$medicationId/stock',
        data: {'stockQuantity': stockQuantity},
      );

      if (response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : response.data['data'];
        return PharmacyMedicationInventory.fromJson(
          data as Map<String, dynamic>,
        );
      }
      throw Exception(
        'Erreur lors de la mise à jour du stock: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Mettre à jour le prix d'un médicament
  /// PATCH /api/v1/pharmacies/{pharmacyId}/medications/{medicationId}/price
  Future<PharmacyMedicationInventory> updatePrice(
    String pharmacyId,
    String medicationId,
    double price,
  ) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.pharmacyMedications(pharmacyId)}/$medicationId/price',
        data: {'price': price},
      );

      if (response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : response.data['data'];
        return PharmacyMedicationInventory.fromJson(
          data as Map<String, dynamic>,
        );
      }
      throw Exception(
        'Erreur lors de la mise à jour du prix: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Supprimer un médicament de l'inventaire
  /// DELETE /api/v1/pharmacies/{pharmacyId}/medications/{medicationId}
  Future<void> removeMedication(String pharmacyId, String medicationId) async {
    try {
      final response = await _dio.delete(
        '${ApiConstants.pharmacyMedications(pharmacyId)}/$medicationId',
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
