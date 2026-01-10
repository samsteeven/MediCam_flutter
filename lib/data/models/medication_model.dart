import 'dart:math' as math;

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
    return Medication(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      genericName: json['genericName'] as String?,
      therapeuticClass:
          TherapeuticClass.fromString(json['therapeuticClass'] as String?) ??
          TherapeuticClass.AUTRES,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      requiresPrescription: json['requiresPrescription'] as bool? ?? false,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : DateTime.now(),
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
              ? Pharmacy.fromJson(json['pharmacy'] as Map<String, dynamic>)
              : Pharmacy(
                id: json['pharmacyId'] as String? ?? '',
                name: json['pharmacyName'] as String? ?? 'Pharmacie inconnue',
                address: '',
                city: '',
                phone: '',
                latitude: 0.0,
                longitude: 0.0,
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

class Pharmacy {
  final String id;
  final String name;
  final String address;
  final String city;
  final String phone;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  Pharmacy({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pharmacy.fromJson(Map<String, dynamic> json) {
    return Pharmacy(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  double calculateDistance(double myLatitude, double myLongitude) {
    // Formule de Haversine pour calculer la distance en km
    const earthRadius = 6371; // km
    final dLat = _degreesToRadians(latitude - myLatitude);
    final dLon = _degreesToRadians(longitude - myLongitude);
    final a =
        (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        (math.cos(_degreesToRadians(myLatitude)) *
            math.cos(_degreesToRadians(latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2));
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}
