import 'package:easypharma_flutter/data/models/pharmacy_model.dart';

enum TherapeuticClass {
  ANTALGIQUE,
  ANTIBIOTIQUE,
  ANTIPALUDEEN,
  ANTIHYPERTENSEUR,
  ANTIDIABETIQUE,
  ANTIINFLAMMATOIRE,
  ANTIHISTAMINIQUE,
  AUTRES;

  String get displayName {
    switch (this) {
      case TherapeuticClass.ANTALGIQUE:
        return 'Antalgique';
      case TherapeuticClass.ANTIBIOTIQUE:
        return 'Antibiotique';
      case TherapeuticClass.ANTIPALUDEEN:
        return 'Antipaludéen';
      case TherapeuticClass.ANTIHYPERTENSEUR:
        return 'Antihypertenseur';
      case TherapeuticClass.ANTIDIABETIQUE:
        return 'Antidiabétique';
      case TherapeuticClass.ANTIINFLAMMATOIRE:
        return 'Anti-inflammatoire';
      case TherapeuticClass.ANTIHISTAMINIQUE:
        return 'Antihistaminique';
      case TherapeuticClass.AUTRES:
        return 'Autres';
    }
  }

  static TherapeuticClass? fromString(String? value) {
    if (value == null) return null;
    return TherapeuticClass.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => TherapeuticClass.AUTRES,
    );
  }
}

class Medication {
  final String id;
  final String name;
  final String? genericName;
  final TherapeuticClass therapeuticClass;
  final String? description;
  final double price;
  final bool requiresPrescription;
  final DateTime createdAt;
  final DateTime updatedAt;

  Medication({
    required this.id,
    required this.name,
    this.genericName,
    required this.therapeuticClass,
    this.description,
    this.price = 0.0,
    this.requiresPrescription = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    String s(dynamic v) => v == null ? '' : v.toString();
    double pd(dynamic v) {
      if (v == null) return 0.0;
      try {
        return double.parse(v.toString());
      } catch (_) {
        return 0.0;
      }
    }

    DateTime pdt(dynamic v) {
      if (v == null) return DateTime.now();
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    bool pb(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      final sVal = s(v).toLowerCase();
      return sVal == 'true' || sVal == '1';
    }

    return Medication(
      id: s(json['id'] ?? json['medicationId'] ?? json['medication_id']),
      name: s(json['name'] ?? json['label'] ?? ''),
      genericName:
          json['genericName'] as String? ?? json['generic_name'] as String?,
      therapeuticClass:
          TherapeuticClass.fromString(json['therapeuticClass'] as String?) ??
          TherapeuticClass.AUTRES,
      description: json['description'] as String? ?? json['desc'] as String?,
      price: pd(json['price'] ?? json['cost']),
      requiresPrescription: pb(
        json['requiresPrescription'] ?? json['requires_prescription'],
      ),
      createdAt: pdt(json['createdAt'] ?? json['created_at']),
      updatedAt: pdt(json['updatedAt'] ?? json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'genericName': genericName,
      'therapeuticClass': therapeuticClass.toString().split('.').last,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class PharmacyMedication {
  final String id;
  final String medicationId;
  final String pharmacyId;
  final double price;
  final int stockQuantity;
  final Medication medication;
  final Pharmacy pharmacy;

  PharmacyMedication({
    required this.id,
    required this.medicationId,
    required this.pharmacyId,
    required this.price,
    required this.stockQuantity,
    required this.medication,
    required this.pharmacy,
  });

  factory PharmacyMedication.fromJson(Map<String, dynamic> json) {
    return PharmacyMedication(
      id: json['id'] as String? ?? '',
      medicationId: json['medicationId'] as String? ?? '',
      pharmacyId: json['pharmacyId'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      // Backend Java retourne stockQuantity
      stockQuantity: _parseQuantityInStock(
        json['stockQuantity'] ??
            json['quantityInStock'] ??
            json['stock'] ??
            json['quantity'],
      ),
      medication:
          json['medication'] != null
              ? Medication.fromJson(json['medication'] as Map<String, dynamic>)
              : Medication(
                id: json['medicationId'] as String? ?? '',
                // Essayer de récupérer le nom depuis le niveau supérieur si medication est null
                name: json['medicationName'] as String? ?? 'Médicament inconnu',
                therapeuticClass: TherapeuticClass.AUTRES,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
      pharmacy:
          json['pharmacy'] != null
              ? Pharmacy.fromJson({
                ...(json['pharmacy'] as Map<String, dynamic>),
                // Aggressively inject any rating found at the top level into the pharmacy object
                if (json['averageRating'] != null)
                  'averageRating': json['averageRating'],
                if (json['avgRating'] != null)
                  'averageRating': json['avgRating'],
                if (json['pharmacyRating'] != null)
                  'averageRating': json['pharmacyRating'],
                if (json['rating'] != null) 'averageRating': json['rating'],
                if (json['ratingCount'] != null)
                  'ratingCount': json['ratingCount'],
                if (json['pharmacyId'] != null) 'id': json['pharmacyId'],
                if (json['pharmacyName'] != null) 'name': json['pharmacyName'],
              })
              : Pharmacy(
                id:
                    json['pharmacyId'] as String? ??
                    json['pharmacy_id'] as String? ??
                    '',
                name:
                    json['pharmacyName'] as String? ??
                    json['pharmacy_name'] as String? ??
                    'Pharmacie inconnue',
                address:
                    json['pharmacyAddress'] as String? ??
                    json['pharmacy_address'] as String? ??
                    '',
                city:
                    json['pharmacyCity'] as String? ??
                    json['pharmacy_city'] as String? ??
                    '',
                phone:
                    json['pharmacyPhone'] as String? ??
                    json['pharmacy_phone'] as String? ??
                    '',
                latitude: (json['pharmacyLatitude'] as num?)?.toDouble() ?? 0.0,
                longitude:
                    (json['pharmacyLongitude'] as num?)?.toDouble() ?? 0.0,
                averageRating:
                    (json['pharmacyRating'] as num?)?.toDouble() ??
                    (json['averageRating'] as num?)?.toDouble() ??
                    (json['rating'] as num?)?.toDouble() ??
                    (json['avgRating'] as num?)?.toDouble() ??
                    0.0,
                ratingCount:
                    (json['pharmacyRatingCount'] as num?)?.toInt() ??
                    (json['ratingCount'] as num?)?.toInt() ??
                    0,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'pharmacyId': pharmacyId,
      'price': price,
      'stockQuantity': stockQuantity,
      'medication': medication.toJson(),
      'pharmacy': pharmacy.toJson(),
    };
  }

  /// Conversion sûre du champ quantité en stock
  /// Gère les types : int, double, String, null
  static int _parseQuantityInStock(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return 0;
      }
    }
    // Type inconnu
    return 0;
  }
}
