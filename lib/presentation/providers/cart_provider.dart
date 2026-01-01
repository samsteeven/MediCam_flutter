import 'package:flutter/foundation.dart';
import 'package:easypharma_flutter/data/models/cart_item_model.dart';
import 'package:easypharma_flutter/data/models/medication_model.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  bool get requiresPrescription {
    return _items.values.any((item) => item.medication.requiresPrescription);
  }

  void addItem(Medication medication, Pharmacy pharmacy, double price) {
    if (_items.containsKey(medication.id)) {
      _items.update(
        medication.id,
        (existing) => existing.copyWith(quantity: existing.quantity + 1),
      );
    } else {
      _items.putIfAbsent(
        medication.id,
        () => CartItem(
          id: DateTime.now().toString(),
          medication: medication,
          pharmacy: pharmacy,
          price: price,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String medicationId) {
    _items.remove(medicationId);
    notifyListeners();
  }

  void updateQuantity(String medicationId, int quantity) {
    if (quantity <= 0) {
      removeItem(medicationId);
      return;
    }
    if (_items.containsKey(medicationId)) {
      _items.update(
        medicationId,
        (existing) => existing.copyWith(quantity: quantity),
      );
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
