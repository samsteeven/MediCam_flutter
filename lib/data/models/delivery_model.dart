import 'package:easypharma_flutter/data/models/order_model.dart';

enum DeliveryStatus {
  PENDING,
  ASSIGNED,
  PICKED_UP,
  IN_TRANSIT,
  DELIVERED,
  CANCELLED;

  String get displayName {
    switch (this) {
      case DeliveryStatus.PENDING:
        return 'En attente';
      case DeliveryStatus.ASSIGNED:
        return 'Assignée';
      case DeliveryStatus.PICKED_UP:
        return 'Récupérée';
      case DeliveryStatus.IN_TRANSIT:
        return 'En cours';
      case DeliveryStatus.DELIVERED:
        return 'Livrée';
      case DeliveryStatus.CANCELLED:
        return 'Annulée';
    }
  }

  static DeliveryStatus fromString(String status) {
    return DeliveryStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => DeliveryStatus.PENDING,
    );
  }
}

class Delivery {
  final String id;
  final String orderId;
  final String? driverId;
  final DeliveryStatus status;
  final DateTime? assignedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final String? proofUrl;
  final Order? order;

  Delivery({
    required this.id,
    required this.orderId,
    this.driverId,
    required this.status,
    this.assignedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.proofUrl,
    this.order,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'] as String? ?? '',
      orderId:
          json['orderId'] as String? ?? (json['order']?['id'] as String? ?? ''),
      driverId: json['driverId'] as String?,
      status: DeliveryStatus.fromString(json['status'] as String? ?? 'PENDING'),
      assignedAt:
          json['assignedAt'] != null
              ? DateTime.parse(json['assignedAt'] as String)
              : null,
      pickedUpAt:
          json['pickedUpAt'] != null
              ? DateTime.parse(json['pickedUpAt'] as String)
              : null,
      deliveredAt:
          json['deliveredAt'] != null
              ? DateTime.parse(json['deliveredAt'] as String)
              : null,
      proofUrl: json['proofUrl'] as String?,
      order:
          json['order'] != null
              ? Order.fromJson(json['order'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'driverId': driverId,
      'status': status.name,
      'assignedAt': assignedAt?.toIso8601String(),
      'pickedUpAt': pickedUpAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'proofUrl': proofUrl,
      'order': order?.toJson(),
    };
  }
}

class DeliveryStats {
  final int totalDeliveries;
  final int completedDeliveries;
  final int ongoingDeliveries;
  final double totalEarnings;

  DeliveryStats({
    required this.totalDeliveries,
    required this.completedDeliveries,
    required this.ongoingDeliveries,
    required this.totalEarnings,
  });

  factory DeliveryStats.fromJson(Map<String, dynamic> json) {
    return DeliveryStats(
      totalDeliveries: json['totalDeliveries'] as int? ?? 0,
      completedDeliveries: json['completedDeliveries'] as int? ?? 0,
      ongoingDeliveries: json['ongoingDeliveries'] as int? ?? 0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
