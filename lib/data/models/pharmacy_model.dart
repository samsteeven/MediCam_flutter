enum PharmacyStatus {
  PENDING,
  APPROVED,
  SUSPENDED;

  String get displayName {
    switch (this) {
      case PharmacyStatus.PENDING:
        return 'En attente';
      case PharmacyStatus.APPROVED:
        return 'Approuvée';
      case PharmacyStatus.SUSPENDED:
        return 'Suspendue';
    }
  }

  static PharmacyStatus? fromString(String? value) {
    if (value == null) return null;
    return PharmacyStatus.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => PharmacyStatus.PENDING,
    );
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
  final String? licenseNumber;
  final PharmacyStatus status;
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
    this.licenseNumber,
    this.status = PharmacyStatus.PENDING,
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
      licenseNumber: json['licenseNumber'] as String?,
      status:
          PharmacyStatus.fromString(json['status'] as String?) ??
          PharmacyStatus.PENDING,
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
      'licenseNumber': licenseNumber,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class PharmacyMedicationInventory {
  final String id;
  final String medicationId;
  final String pharmacyId;
  final double price;
  final int quantityInStock;
  final DateTime createdAt;
  final DateTime updatedAt;

  PharmacyMedicationInventory({
    required this.id,
    required this.medicationId,
    required this.pharmacyId,
    required this.price,
    required this.quantityInStock,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PharmacyMedicationInventory.fromJson(Map<String, dynamic> json) {
    return PharmacyMedicationInventory(
      id: json['id'] as String? ?? '',
      medicationId: json['medicationId'] as String? ?? '',
      pharmacyId: json['pharmacyId'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantityInStock: json['quantityInStock'] as int? ?? 0,
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
      'medicationId': medicationId,
      'pharmacyId': pharmacyId,
      'price': price,
      'quantityInStock': quantityInStock,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
