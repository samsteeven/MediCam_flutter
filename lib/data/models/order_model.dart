enum OrderStatus {
  PENDING,
  PAID,
  CONFIRMED,
  PREPARING,
  READY,
  IN_DELIVERY,
  DELIVERED,
  CANCELLED;

  String get displayName {
    switch (this) {
      case OrderStatus.PENDING:
        return 'En attente';
      case OrderStatus.PAID:
        return 'Payée';
      case OrderStatus.CONFIRMED:
        return 'Confirmée';
      case OrderStatus.PREPARING:
        return 'En préparation';
      case OrderStatus.READY:
        return 'Prête';
      case OrderStatus.IN_DELIVERY:
        return 'En livraison';
      case OrderStatus.DELIVERED:
        return 'Livrée';
      case OrderStatus.CANCELLED:
        return 'Annulée';
    }
  }

  static OrderStatus fromString(String? value) {
    if (value == null) return OrderStatus.PENDING;
    final s = value.toString().toUpperCase().replaceAll('-', '_');
    switch (s) {
      case 'PENDING':
        return OrderStatus.PENDING;
      case 'PAID':
      case 'PAYED':
        return OrderStatus.PAID;
      case 'CONFIRMED':
      case 'CONFIRME':
        return OrderStatus.CONFIRMED;
      case 'PREPARING':
      case 'PREPARATION':
        return OrderStatus.PREPARING;
      case 'READY':
      case 'READY_FOR_PICKUP':
        return OrderStatus.READY;
      case 'IN_DELIVERY':
      case 'DELIVERING':
        return OrderStatus.IN_DELIVERY;
      case 'DELIVERED':
        return OrderStatus.DELIVERED;
      case 'CANCELLED':
      case 'CANCELED':
        return OrderStatus.CANCELLED;
      default:
        return OrderStatus.PENDING;
    }
  }
}

class OrderItem {
  final String id;
  final String medicationId;
  final String medicationName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  OrderItem({
    required this.id,
    required this.medicationId,
    this.medicationName = 'Médicament',
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String? ?? '',
      medicationId: json['medicationId'] as String? ?? '',
      medicationName: json['medicationName'] as String? ?? 'Médicament',
      quantity: json['quantity'] as int? ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'medicationName': medicationName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }
}

class Order {
  final String id;
  final String patientId;
  final String pharmacyId;
  final OrderStatus status;
  final List<OrderItem> items;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.patientId,
    required this.pharmacyId,
    required this.status,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // helpers
    String safeString(dynamic v) {
      if (v == null) return '';
      return v.toString();
    }

    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return Order(
      id: safeString(json['id'] ?? json['orderId'] ?? json['order_id']),
      patientId: safeString(
        json['patientId'] ?? json['patient_id'] ?? json['patient'],
      ),
      pharmacyId: safeString(
        json['pharmacyId'] ?? json['pharmacy_id'] ?? json['pharmacy'],
      ),
      status:
          OrderStatus.fromString(json['status'] as String?) ??
          OrderStatus.PENDING,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: parseDouble(
        json['totalAmount'] ?? json['total_amount'] ?? json['amount'],
      ),
      createdAt: parseDate(
        json['createdAt'] ?? json['created_at'] ?? json['created'],
      ),
      updatedAt: parseDate(
        json['updatedAt'] ?? json['updated_at'] ?? json['updated'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'pharmacyId': pharmacyId,
      'status': status.toString().split('.').last,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class CreateOrderRequest {
  final String pharmacyId;
  final List<CreateOrderItem> items;
  final String? deliveryAddress;
  final String? deliveryCity;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final String? deliveryPhone;
  final String? notes;

  CreateOrderRequest({
    required this.pharmacyId,
    required this.items,
    this.deliveryAddress,
    this.deliveryCity,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.deliveryPhone,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'pharmacyId': pharmacyId,
      'items': items.map((item) => item.toJson()).toList(),
      // Champs d'adresse fournis pour éviter des contraintes NOT NULL côté backend
      'deliveryAddress': deliveryAddress ?? '',
      'deliveryCity': deliveryCity ?? '',
      'deliveryLatitude': deliveryLatitude,
      'deliveryLongitude': deliveryLongitude,
      'deliveryPhone': deliveryPhone ?? '',
      'notes': notes ?? '',
    };
  }
}

class CreateOrderItem {
  final String medicationId;
  final int quantity;

  CreateOrderItem({required this.medicationId, required this.quantity});

  Map<String, dynamic> toJson() {
    return {'medicationId': medicationId, 'quantity': quantity};
  }
}
