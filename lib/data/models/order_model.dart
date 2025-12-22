enum OrderStatus {
  PENDING,
  CONFIRMED,
  PREPARED,
  READY_FOR_PICKUP,
  COMPLETED,
  CANCELLED;

  String get displayName {
    switch (this) {
      case OrderStatus.PENDING:
        return 'En attente';
      case OrderStatus.CONFIRMED:
        return 'Confirmée';
      case OrderStatus.PREPARED:
        return 'En préparation';
      case OrderStatus.READY_FOR_PICKUP:
        return 'Prête à récupérer';
      case OrderStatus.COMPLETED:
        return 'Complétée';
      case OrderStatus.CANCELLED:
        return 'Annulée';
    }
  }

  static OrderStatus? fromString(String? value) {
    if (value == null) return null;
    return OrderStatus.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => OrderStatus.PENDING,
    );
  }
}

class OrderItem {
  final String id;
  final String medicationId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  OrderItem({
    required this.id,
    required this.medicationId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String? ?? '',
      medicationId: json['medicationId'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
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
    return Order(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      pharmacyId: json['pharmacyId'] as String? ?? '',
      status:
          OrderStatus.fromString(json['status'] as String?) ??
          OrderStatus.PENDING,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
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

  CreateOrderRequest({required this.pharmacyId, required this.items});

  Map<String, dynamic> toJson() {
    return {
      'pharmacyId': pharmacyId,
      'items': items.map((item) => item.toJson()).toList(),
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
