import 'package:easypharma_flutter/data/models/order_model.dart';

enum DeliveryStatus {
  ASSIGNED,
  PICKED_UP,
  IN_TRANSIT,
  DELIVERED,
  FAILED;

  String get displayName {
    switch (this) {
      case DeliveryStatus.ASSIGNED:
        return 'Assignée';
      case DeliveryStatus.PICKED_UP:
        return 'Récupérée';
      case DeliveryStatus.IN_TRANSIT:
        return 'En transit';
      case DeliveryStatus.DELIVERED:
        return 'Livrée';
      case DeliveryStatus.FAILED:
        return 'Échouée';
    }
  }

  static DeliveryStatus fromString(String? status) {
    if (status == null) return DeliveryStatus.ASSIGNED;
    final s = status.toUpperCase().replaceAll('-', '_');
    switch (s) {
      case 'ASSIGNED':
        return DeliveryStatus.ASSIGNED;
      case 'PICKED_UP':
      case 'PICKED-UP':
        return DeliveryStatus.PICKED_UP;
      case 'IN_TRANSIT':
      case 'IN-TRANSIT':
        return DeliveryStatus.IN_TRANSIT;
      case 'DELIVERED':
        return DeliveryStatus.DELIVERED;
      case 'FAILED':
        return DeliveryStatus.FAILED;
      default:
        return DeliveryStatus.ASSIGNED;
    }
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
  final double? currentLatitude;
  final double? currentLongitude;
  final String? deliveryPersonName;
  final String? deliveryAddress;
  final String? deliveryCity;
  final String? deliveryPhone;
  final String? patientName;
  final String? orderNumber;

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
    this.currentLatitude,
    this.currentLongitude,
    this.deliveryPersonName,
    this.deliveryAddress,
    this.deliveryCity,
    this.deliveryPhone,
    this.patientName,
    this.orderNumber,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      // backend uses deliveryId, deliveryPersonId, photoProofUrl
      id: (json['deliveryId'] as String?) ?? (json['id'] as String?) ?? '',
      orderId:
          (json['orderId'] as String?) ??
          (json['order']?['id'] as String?) ??
          '',
      driverId:
          (json['deliveryPersonId'] as String?) ??
          (json['driverId'] as String?),
      status: DeliveryStatus.fromString(json['status'] as String?),
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
      proofUrl:
          (json['photoProofUrl'] as String?) ?? (json['proofUrl'] as String?),
      // Additional backend fields
      currentLatitude:
          json['currentLatitude'] != null
              ? (json['currentLatitude'] is num
                  ? (json['currentLatitude'] as num).toDouble()
                  : double.tryParse(json['currentLatitude'].toString()))
              : (json['current_latitude'] is num
                  ? (json['current_latitude'] as num).toDouble()
                  : double.tryParse(
                    (json['current_latitude'] ?? '').toString(),
                  )),
      currentLongitude:
          json['currentLongitude'] != null
              ? (json['currentLongitude'] is num
                  ? (json['currentLongitude'] as num).toDouble()
                  : double.tryParse(json['currentLongitude'].toString()))
              : (json['current_longitude'] is num
                  ? (json['current_longitude'] as num).toDouble()
                  : double.tryParse(
                    (json['current_longitude'] ?? '').toString(),
                  )),
      deliveryPersonName:
          (json['deliveryPersonName'] as String?) ??
          (json['deliveryPersonName'] as String?) ??
          (json['deliveryPersonName'] as String?),
      deliveryAddress:
          (json['deliveryAddress'] as String?) ??
          (json['delivery_address'] as String?) ??
          (json['deliveryAddress'] as String?),
      deliveryCity:
          (json['deliveryCity'] as String?) ??
          (json['delivery_city'] as String?) ??
          (json['deliveryCity'] as String?),
      deliveryPhone:
          (json['deliveryPhone'] as String?) ??
          (json['delivery_phone'] as String?) ??
          (json['deliveryPhone'] as String?),
      patientName:
          (json['patientName'] as String?) ??
          (json['patient_name'] as String?) ??
          (json['patientName'] as String?),
      orderNumber:
          (json['orderNumber'] as String?) ??
          (json['order_number'] as String?) ??
          (json['orderNumber'] as String?),
      order:
          json['order'] != null
              ? Order.fromJson(json['order'] as Map<String, dynamic>)
              : Order(
                id: (json['orderId'] as String?) ?? '',
                patientId: '',
                pharmacyId: '',
                status: OrderStatus.PENDING,
                items: [],
                totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
                createdAt:
                    json['createdAt'] != null
                        ? DateTime.parse(json['createdAt'] as String)
                        : DateTime.now(),
                updatedAt:
                    json['updatedAt'] != null
                        ? DateTime.parse(json['updatedAt'] as String)
                        : DateTime.now(),
              ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // Provide both legacy front keys and backend DTO keys for compatibility
      'id': id,
      'deliveryId': id,
      'orderId': orderId,
      'driverId': driverId,
      'deliveryPersonId': driverId,
      'status': status.name,
      'assignedAt': assignedAt?.toIso8601String(),
      'pickedUpAt': pickedUpAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'proofUrl': proofUrl,
      'photoProofUrl': proofUrl,
      'order': order?.toJson(),
      // Backend-compatible fields
      'currentLatitude': currentLatitude,
      'currentLongitude': currentLongitude,
      'deliveryPersonName': deliveryPersonName,
      'deliveryAddress': deliveryAddress,
      'deliveryCity': deliveryCity,
      'deliveryPhone': deliveryPhone,
      'patientName': patientName,
      'orderNumber': orderNumber,
    };
  }
}

class DeliveryStats {
  final int totalDeliveries;
  final int completedDeliveries;
  final int failedDeliveries;
  final int ongoingDeliveries;
  final double totalEarnings;
  final double averageDeliveryTimeMinutes;
  final double successRate;
  final double averageRating;

  DeliveryStats({
    required this.totalDeliveries,
    required this.completedDeliveries,
    required this.failedDeliveries,
    required this.ongoingDeliveries,
    required this.totalEarnings,
    required this.averageDeliveryTimeMinutes,
    required this.successRate,
    this.averageRating = 0.0,
  });

  factory DeliveryStats.fromJson(Map<String, dynamic> json) {
    // Backend may provide either a global shape or more detailed metrics
    final completed =
        (json['completedDeliveries'] as num?)?.toInt() ??
        (json['completed'] as num?)?.toInt() ??
        0;
    final failed =
        (json['failedDeliveries'] as num?)?.toInt() ??
        (json['failed'] as num?)?.toInt() ??
        0;
    final ongoing =
        (json['ongoingDeliveries'] as num?)?.toInt() ??
        (json['ongoing'] as num?)?.toInt() ??
        0;
    final total =
        (json['totalDeliveries'] as num?)?.toInt() ??
        (json['total'] as num?)?.toInt() ??
        (completed + failed + ongoing);
    final earnings =
        (json['totalEarnings'] as num?)?.toDouble() ??
        (json['totalRevenue'] as num?)?.toDouble() ??
        0.0;
    final avgTime =
        (json['averageDeliveryTimeMinutes'] as num?)?.toDouble() ?? 0.0;
    final success = (json['successRate'] as num?)?.toDouble() ?? 0.0;
    final rating =
        (json['averageRating'] as num?)?.toDouble() ??
        (json['rating'] as num?)?.toDouble() ??
        (json['score'] as num?)?.toDouble() ??
        0.0;

    return DeliveryStats(
      totalDeliveries: total,
      completedDeliveries: completed,
      failedDeliveries: failed,
      ongoingDeliveries: ongoing,
      totalEarnings: earnings,
      averageDeliveryTimeMinutes: avgTime,
      successRate: success,
      averageRating: rating,
    );
  }
}
