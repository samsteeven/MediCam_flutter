import 'package:flutter_test/flutter_test.dart';
import 'package:easypharma_flutter/data/models/delivery_model.dart';

void main() {
  group('Delivery.fromJson', () {
    test('parses minimal delivery with legacy keys', () {
      final json = {
        'deliveryId': 'D-1',
        'orderId': 'O-1',
        'status': 'DELIVERED',
        'assignedAt': '2024-01-01T12:00:00Z',
        'currentLatitude': 10.5,
        'currentLongitude': '20.25',
        'deliveryPersonName': 'Jean',
        'patientName': 'Alice',
        'orderNumber': 'ORD-100',
      };

      final d = Delivery.fromJson(json);

      expect(d.id, 'D-1');
      expect(d.orderId, 'O-1');
      expect(d.status, DeliveryStatus.DELIVERED);
      expect(d.assignedAt, isNotNull);
      expect(d.currentLatitude, 10.5);
      expect(d.currentLongitude, 20.25);
      expect(d.deliveryPersonName, 'Jean');
      expect(d.patientName, 'Alice');
      expect(d.orderNumber, 'ORD-100');
    });

    test('parses nested order object', () {
      final json = {
        'id': 'D-2',
        'order': {
          'id': 'O-2',
          'patientId': 'U-1',
          'pharmacyId': 'PH-1',
          'status': 'PENDING',
          'items': [],
          'totalAmount': 5.5,
          'createdAt': '2025-01-01T10:00:00Z',
          'updatedAt': '2025-01-01T10:00:00Z',
        },
      };

      final d = Delivery.fromJson(json);
      expect(d.order, isNotNull);
      expect(d.order?.id, 'O-2');
    });
  });
}
