import 'package:easypharma_flutter/data/models/medication_model.dart';
import 'package:easypharma_flutter/data/models/pharmacy_model.dart';

class CartItem {
  final String id;
  final Medication medication;
  final Pharmacy pharmacy;
  int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.medication,
    required this.pharmacy,
    this.quantity = 1,
    required this.price,
  });

  double get total => price * quantity;

  CartItem copyWith({
    String? id,
    Medication? medication,
    Pharmacy? pharmacy,
    int? quantity,
    double? price,
  }) {
    return CartItem(
      id: id ?? this.id,
      medication: medication ?? this.medication,
      pharmacy: pharmacy ?? this.pharmacy,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medication.id,
      'pharmacyId': pharmacy.id,
      'quantity': quantity,
      'price': price,
    };
  }
}
