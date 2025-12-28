enum DeliveryStatus {
  PENDING,
  ASSIGNED,
  PICKED_UP,
  DELIVERED,
  FAILED,
  CANCELLED;

  String get displayName {
    switch (this) {
      case DeliveryStatus.PENDING:
        return 'En attente';
      case DeliveryStatus.ASSIGNED:
        return 'Assignée';
      case DeliveryStatus.PICKED_UP:
        return 'Récupérée';
      case DeliveryStatus.DELIVERED:
        return 'Livrée';
      case DeliveryStatus.FAILED:
        return 'Échouée';
      case DeliveryStatus.CANCELLED:
        return 'Annulée';
    }
  }

  static DeliveryStatus fromString(String? value) {
    if (value == null) return DeliveryStatus.PENDING;
    return DeliveryStatus.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => DeliveryStatus.PENDING,
    );
  }
}

class Delivery {
  final String id;
  final String orderId;
  final DeliveryStatus status;
  final String? customerName;
  final String? customerPhone;
  final String? deliveryAddress;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final String? pharmacyName;
  final String? pharmacyAddress;
  final double? pharmacyLatitude;
  final double? pharmacyLongitude;
  final double? distance; // Distance estimée
  final String? proofUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Delivery({
    required this.id,
    required this.orderId,
    required this.status,
    this.customerName,
    this.customerPhone,
    this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.pharmacyName,
    this.pharmacyAddress,
    this.pharmacyLatitude,
    this.pharmacyLongitude,
    this.distance,
    this.proofUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      status: DeliveryStatus.fromString(json['status'] as String?),
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      deliveryAddress: json['deliveryAddress'] as String?,
      deliveryLatitude: (json['deliveryLatitude'] as num?)?.toDouble(),
      deliveryLongitude: (json['deliveryLongitude'] as num?)?.toDouble(),
      pharmacyName: json['pharmacyName'] as String?,
      pharmacyAddress: json['pharmacyAddress'] as String?,
      pharmacyLatitude: (json['pharmacyLatitude'] as num?)?.toDouble(),
      pharmacyLongitude: (json['pharmacyLongitude'] as num?)?.toDouble(),
      distance: (json['distance'] as num?)?.toDouble(),
      proofUrl: json['proofUrl'] as String?,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'status': status.toString().split('.').last,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'deliveryAddress': deliveryAddress,
      'deliveryLatitude': deliveryLatitude,
      'deliveryLongitude': deliveryLongitude,
      'pharmacyName': pharmacyName,
      'pharmacyAddress': pharmacyAddress,
      'pharmacyLatitude': pharmacyLatitude,
      'pharmacyLongitude': pharmacyLongitude,
      'distance': distance,
      'proofUrl': proofUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class DeliveryStats {
  final int successfulDeliveries;
  final int failedDeliveries;
  final int pendingDeliveries;
  final int totalDeliveries;
  final double? totalEarnings; // Optionnel si disponible

  DeliveryStats({
    this.successfulDeliveries = 0,
    this.failedDeliveries = 0,
    this.pendingDeliveries = 0,
    this.totalDeliveries = 0,
    this.totalEarnings,
  });

  factory DeliveryStats.fromJson(Map<String, dynamic> json) {
    return DeliveryStats(
      successfulDeliveries: json['successfulDeliveries'] as int? ?? 0,
      failedDeliveries: json['failedDeliveries'] as int? ?? 0,
      pendingDeliveries: json['pendingDeliveries'] as int? ?? 0,
      totalDeliveries: json['totalDeliveries'] as int? ?? 0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble(),
    );
  }
}
