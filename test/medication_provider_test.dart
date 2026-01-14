import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:easypharma_flutter/data/models/medication_model.dart';
import 'package:easypharma_flutter/data/models/pharmacy_model.dart';

import 'package:easypharma_flutter/data/repositories/medication_repository.dart';
import 'package:easypharma_flutter/presentation/providers/medication_provider.dart';
import 'package:easypharma_flutter/core/constants/api_constants.dart';

// Mock Dio
class MockDio extends Mock implements Dio {}

void main() {
  group('MedicationRepository Tests', () {
    late MedicationRepository repository;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      repository = MedicationRepository(mockDio);
    });

    test(
      'searchMedications should return list of pharmacy medications',
      () async {
        // Arrange
        final mockResponse = Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: [
            {
              'id': '1',
              'medicationId': 'med-1',
              'pharmacyId': 'pharm-1',
              'price': 2500.0,
              'stockQuantity': 100,
              'medication': {
                'id': 'med-1',
                'name': 'Paracétamol',
                'therapeuticClass': 'ANTALGIQUE',
                'createdAt': DateTime.now().toIso8601String(),
                'updatedAt': DateTime.now().toIso8601String(),
              },
              'pharmacy': {
                'id': 'pharm-1',
                'name': 'Pharmacie A',
                'address': 'Rue 1',
                'city': 'Dakar',
                'phone': '221771234567',
                'latitude': 14.6928,
                'longitude': -17.0467,
                'createdAt': DateTime.now().toIso8601String(),
                'updatedAt': DateTime.now().toIso8601String(),
              },
            },
          ],
        );

        when(
          () => mockDio.get(
            ApiConstants.patientSearch,
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await repository.searchMedications(name: 'Paracétamol');

        // Assert
        expect(result, isA<List<PharmacyMedication>>());
        expect(result.length, 1);
        expect(result[0].medication.name, 'Paracétamol');
        expect(result[0].stockQuantity, 100);
      },
    );

    test('getPricesAcrossPharmacies should return sorted prices', () async {
      // Arrange
      final mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: [
          {
            'id': '1',
            'medicationId': 'med-1',
            'pharmacyId': 'pharm-1',
            'price': 2500.0,
            'stockQuantity': 50,
            'medication': {
              'id': 'med-1',
              'name': 'Paracétamol',
              'therapeuticClass': 'ANTALGIQUE',
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            },
            'pharmacy': {
              'id': 'pharm-1',
              'name': 'Pharmacie A',
              'address': 'Rue 1',
              'city': 'Dakar',
              'phone': '221771234567',
              'latitude': 14.6928,
              'longitude': -17.0467,
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            },
          },
        ],
      );

      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.getPricesAcrossPharmacies(
        medicationId: 'med-1',
      );

      // Assert
      expect(result, isA<List<PharmacyMedication>>());
      expect(result.length, 1);
      expect(result[0].price, 2500.0);
    });

    test(
      'getNearbyPharmacies should return pharmacies within radius',
      () async {
        // Arrange
        final mockResponse = Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: [
            {
              'id': 'pharm-1',
              'name': 'Pharmacie Centrale',
              'address': 'Rue Principale',
              'city': 'Dakar',
              'phone': '221771234567',
              'latitude': 14.6928,
              'longitude': -17.0467,
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            },
          ],
        );

        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await repository.getNearbyPharmacies(
          latitude: 14.6928,
          longitude: -17.0467,
          radiusKm: 5,
        );

        // Assert
        expect(result, isA<List<Pharmacy>>());
        expect(result.length, 1);
        expect(result[0].name, 'Pharmacie Centrale');
      },
    );
  });

  group('MedicationProvider Tests', () {
    late MedicationProvider provider;
    late MockDio mockDio;
    late MedicationRepository repository;

    setUp(() {
      mockDio = MockDio();
      repository = MedicationRepository(mockDio);
      provider = MedicationProvider(repository);
    });

    test('Initial state should be empty', () {
      expect(provider.searchResults, isEmpty);
      expect(provider.priceResults, isEmpty);
      expect(provider.nearbyPharmacies, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNull);
    });

    test('searchMedications should update state', () async {
      // Arrange
      final mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: [
          {
            'id': '1',
            'medicationId': 'med-1',
            'pharmacyId': 'pharm-1',
            'price': 2500.0,
            'stockQuantity': 100,
            'medication': {
              'id': 'med-1',
              'name': 'Paracétamol',
              'therapeuticClass': 'ANTALGIQUE',
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            },
            'pharmacy': {
              'id': 'pharm-1',
              'name': 'Pharmacie A',
              'address': 'Rue 1',
              'city': 'Dakar',
              'phone': '221771234567',
              'latitude': 14.6928,
              'longitude': -17.0467,
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            },
          },
        ],
      );

      when(
        () => mockDio.get(
          ApiConstants.patientSearch,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      await provider.searchMedications('Paracétamol');

      // Assert
      expect(provider.searchResults, isNotEmpty);
      expect(provider.searchResults[0].medication.name, 'Paracétamol');
      expect(provider.isLoading, false);
    });

    test('filterByTherapeuticClass should filter results', () async {
      // Arrange
      final p1 = Pharmacy(
        id: 'p1',
        name: 'Pharm 1',
        address: '',
        city: '',
        phone: '',
        latitude: 0,
        longitude: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      provider.setSearchResultsForTest([
        PharmacyMedication(
          id: '1',
          medicationId: 'm1',
          pharmacyId: 'p1',
          price: 1000,
          stockQuantity: 10,
          medication: Medication(
            id: 'm1',
            name: 'Paracétamol',
            therapeuticClass: TherapeuticClass.ANTALGIQUE,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          pharmacy: p1,
        ),
        PharmacyMedication(
          id: '2',
          medicationId: 'm2',
          pharmacyId: 'p1',
          price: 2000,
          stockQuantity: 10,
          medication: Medication(
            id: 'm2',
            name: 'Amoxicilline',
            therapeuticClass: TherapeuticClass.ANTIBIOTIQUE,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          pharmacy: p1,
        ),
      ]);

      // Act
      provider.filterByTherapeuticClass(TherapeuticClass.ANTALGIQUE);

      // Assert
      expect(provider.searchResults.length, 1);
      expect(
        provider.searchResults[0].medication.therapeuticClass,
        TherapeuticClass.ANTALGIQUE,
      );
    });

    test('filterByPriceRange should return filtered prices', () {
      // Arrange
      provider.setPriceResultsForTest([
        PharmacyMedication(
          id: '1',
          medicationId: 'med-1',
          pharmacyId: 'pharm-1',
          price: 2000.0,
          stockQuantity: 10,
          medication: Medication(
            id: 'med-1',
            name: 'Med 1',
            therapeuticClass: TherapeuticClass.AUTRES,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          pharmacy: Pharmacy(
            id: 'pharm-1',
            name: 'Pharm 1',
            address: 'Address',
            city: 'City',
            phone: 'Phone',
            latitude: 0,
            longitude: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ),
        PharmacyMedication(
          id: '2',
          medicationId: 'med-1',
          pharmacyId: 'pharm-2',
          price: 5000.0,
          stockQuantity: 10,
          medication: Medication(
            id: 'med-1',
            name: 'Med 1',
            therapeuticClass: TherapeuticClass.AUTRES,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          pharmacy: Pharmacy(
            id: 'pharm-2',
            name: 'Pharm 2',
            address: 'Address',
            city: 'City',
            phone: 'Phone',
            latitude: 0,
            longitude: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ),
      ]);

      // Act
      final filtered = provider.filterByPriceRange(2500, 6000);

      // Assert
      expect(filtered.length, 1);
      expect(filtered[0].price, 5000.0);
    });

    test('setSortBy should sort results', () {
      // Arrange
      provider.setPriceResultsForTest([
        PharmacyMedication(
          id: '1',
          medicationId: 'med-1',
          pharmacyId: 'pharm-1',
          price: 5000.0,
          stockQuantity: 10,
          medication: Medication(
            id: 'med-1',
            name: 'Med 1',
            therapeuticClass: TherapeuticClass.AUTRES,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          pharmacy: Pharmacy(
            id: 'pharm-1',
            name: 'Pharm 1',
            address: 'Address',
            city: 'City',
            phone: 'Phone',
            latitude: 0,
            longitude: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ),
        PharmacyMedication(
          id: '2',
          medicationId: 'med-1',
          pharmacyId: 'pharm-2',
          price: 2000.0,
          stockQuantity: 10,
          medication: Medication(
            id: 'med-1',
            name: 'Med 1',
            therapeuticClass: TherapeuticClass.AUTRES,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          pharmacy: Pharmacy(
            id: 'pharm-2',
            name: 'Pharm 2',
            address: 'Address',
            city: 'City',
            phone: 'Phone',
            latitude: 0,
            longitude: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ),
      ]);

      // Act
      provider.setSortBy('price');

      // Assert
      expect(provider.priceResults[0].price, 2000.0);
      expect(provider.priceResults[1].price, 5000.0);
    });

    test('clearResults should reset all data', () {
      // Arrange
      provider.setSearchResultsForTest([
        PharmacyMedication(
          id: '1',
          medicationId: 'm1',
          pharmacyId: 'p1',
          price: 1000,
          stockQuantity: 10,
          medication: Medication(
            id: '1',
            name: 'Test',
            therapeuticClass: TherapeuticClass.AUTRES,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          pharmacy: Pharmacy(
            id: 'p1',
            name: '',
            address: '',
            city: '',
            phone: '',
            latitude: 0,
            longitude: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ),
      ]);

      // Act
      provider.clearResults();

      // Assert
      expect(provider.searchResults, isEmpty);
      expect(provider.priceResults, isEmpty);
      expect(provider.nearbyPharmacies, isEmpty);
      expect(provider.errorMessage, isNull);
    });
  });

  group('Pharmacy Distance Calculation', () {
    test(
      'calculateDistance should return correct distance using Haversine',
      () {
        // Arrange - Dakar coordinates
        final pharmacy = Pharmacy(
          id: '1',
          name: 'Test Pharmacy',
          address: 'Test Address',
          city: 'Dakar',
          phone: '221771234567',
          latitude: 14.6928,
          longitude: -17.0467,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final distance = pharmacy.calculateDistance(14.6928, -17.0467);

        // Assert - Distance should be ~0 km (same location)
        expect(distance, lessThan(1.0));
      },
    );
  });
}
