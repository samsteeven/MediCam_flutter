import 'package:flutter_test/flutter_test.dart';
import 'package:easypharma_flutter/data/models/user_model.dart';

void main() {
  group('User.fromJson', () {
    test('parses different field names and roles', () {
      final json = {
        'userId': 'U-1',
        'mail': 'alice@example.com',
        'first_name': 'Alice',
        'last_name': 'Dupont',
        'telephone': '+33123456789',
        'role': 'PHARMACY_ADMIN',
        'latitude': '48.8566',
        'longitude': 2.3522,
        'active': true,
        'verified': false,
        'created_at': '2023-12-01T09:00:00Z',
      };

      final u = User.fromJson(json);

      expect(u.id, 'U-1');
      expect(u.email, 'alice@example.com');
      expect(u.firstName, 'Alice');
      expect(u.lastName, 'Dupont');
      expect(u.phone, '+33123456789');
      expect(u.role, UserRole.PHARMACY_ADMIN);
      expect(u.latitude, isNotNull);
      expect(u.longitude, isNotNull);
      expect(u.isActive, isTrue);
      expect(u.isVerified, isFalse);
    });
  });
}
