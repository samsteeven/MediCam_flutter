import 'package:flutter/foundation.dart';
import 'package:easypharma_flutter/data/models/cart_item_model.dart';
import 'package:easypharma_flutter/data/models/medication_model.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  int get totalItems {
    int total = 0;
    _items.forEach((key, item) => total += item.quantity);
    return total;
  }

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  double get totalPrice => totalAmount;

  int get pharmacyCount {
    return _items.values.map((item) => item.pharmacy.id).toSet().length;
  }

  Map<String, List<CartItem>> get cartByPharmacy {
    final Map<String, List<CartItem>> grouped = {};
    for (var item in _items.values) {
      if (!grouped.containsKey(item.pharmacy.id)) {
        grouped[item.pharmacy.id] = [];
      }
      grouped[item.pharmacy.id]!.add(item);
    }
    return grouped;
  }

  bool get requiresPrescription {
    return _items.values.any((item) => item.medication.requiresPrescription);
  }

  void addItem(Medication medication, Pharmacy pharmacy, double price) {
    final String key = '${medication.id}_${pharmacy.id}';
    if (_items.containsKey(key)) {
      _items.update(
        key,
        (existing) => existing.copyWith(quantity: existing.quantity + 1),
      );
    } else {
      _items.putIfAbsent(
        key,
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

  void clearCart() => clear();
}
