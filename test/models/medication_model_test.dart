import 'package:flutter_test/flutter_test.dart';
import 'package:easypharma_flutter/data/models/medication_model.dart';

void main() {
  group('Medication.fromJson', () {
    test('parses fields with alternate keys and types', () {
      final json = {
        'medicationId': 'M-1',
        'label': 'Paracétamol',
        'price': '3.50',
        'requires_prescription': 'false',
        'created_at': '2024-06-01T08:00:00Z',
        'updated_at': '2024-06-02T08:00:00Z',
      };

      final m = Medication.fromJson(json);

      expect(m.id, 'M-1');
      expect(m.name, 'Paracétamol');
      expect(m.price, 3.5);
      expect(m.requiresPrescription, isFalse);
      expect(m.createdAt, isA<DateTime>());
    });
  });
}
