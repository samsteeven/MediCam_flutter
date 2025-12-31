import 'package:flutter/material.dart';
// Import du modèle CartItem que nous avons créé
import 'package:easypharma_flutter/data/models/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  // Map avec pharmacyId comme clé et liste d'articles comme valeur
  // Cela permet de grouper les articles par pharmacie
  final Map<String, List<CartItem>> _cartByPharmacy = {};

  // Getters
  Map<String, List<CartItem>> get cartByPharmacy => _cartByPharmacy;

  // Obtenir tous les articles (toutes pharmacies confondues)
  List<CartItem> get allItems {
    return _cartByPharmacy.values.expand((items) => items).toList();
  }

  // Nombre total d'articles
  int get totalItems {
    return allItems.fold(0, (sum, item) => sum + item.quantity);
  }

  // Prix total du panier
  double get totalPrice {
    return allItems.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  // Nombre de pharmacies différentes dans le panier
  int get pharmacyCount => _cartByPharmacy.length;

  // Vérifier si le panier est vide
  bool get isEmpty => _cartByPharmacy.isEmpty;

  // Ajouter un article au panier
  void addItem({
    required String pharmacyId,
    required String pharmacyName,
    required String medicationId,
    required String medicationName,
    required double price,
    required int availableStock,
  }) {
    // Si la pharmacie n'existe pas encore dans le panier, créer une nouvelle liste
    if (!_cartByPharmacy.containsKey(pharmacyId)) {
      _cartByPharmacy[pharmacyId] = [];
    }

    // Vérifier si le médicament existe déjà dans le panier de cette pharmacie
    final existingItemIndex = _cartByPharmacy[pharmacyId]!.indexWhere(
          (item) => item.medicationId == medicationId,
    );

    if (existingItemIndex >= 0) {
      // Le médicament existe déjà, augmenter la quantité
      final existingItem = _cartByPharmacy[pharmacyId]![existingItemIndex];
      if (existingItem.quantity < availableStock) {
        existingItem.quantity++;
      } else {
        // Stock insuffisant
        throw Exception('Stock insuffisant');
      }
    } else {
      // Nouveau médicament, l'ajouter
      _cartByPharmacy[pharmacyId]!.add(
        CartItem(
          pharmacyId: pharmacyId,
          pharmacyName: pharmacyName,
          medicationId: medicationId,
          medicationName: medicationName,
          price: price,
          quantity: 1,
          availableStock: availableStock,
        ),
      );
    }

    notifyListeners();
  }

  // Retirer un article du panier
  void removeItem(String pharmacyId, String medicationId) {
    if (_cartByPharmacy.containsKey(pharmacyId)) {
      _cartByPharmacy[pharmacyId]!.removeWhere(
            (item) => item.medicationId == medicationId,
      );

      // Si la liste est vide, retirer la pharmacie
      if (_cartByPharmacy[pharmacyId]!.isEmpty) {
        _cartByPharmacy.remove(pharmacyId);
      }

      notifyListeners();
    }
  }

  // Mettre à jour la quantité d'un article
  void updateQuantity(String pharmacyId, String medicationId, int newQuantity) {
    if (_cartByPharmacy.containsKey(pharmacyId)) {
      final itemIndex = _cartByPharmacy[pharmacyId]!.indexWhere(
            (item) => item.medicationId == medicationId,
      );

      if (itemIndex >= 0) {
        final item = _cartByPharmacy[pharmacyId]![itemIndex];

        if (newQuantity <= 0) {
          // Si la quantité est 0 ou négative, retirer l'article
          removeItem(pharmacyId, medicationId);
        } else if (newQuantity <= item.availableStock) {
          // Mettre à jour la quantité
          item.quantity = newQuantity;
          notifyListeners();
        } else {
          throw Exception('Stock insuffisant');
        }
      }
    }
  }

  // Augmenter la quantité d'un article
  void incrementQuantity(String pharmacyId, String medicationId) {
    if (_cartByPharmacy.containsKey(pharmacyId)) {
      final itemIndex = _cartByPharmacy[pharmacyId]!.indexWhere(
            (item) => item.medicationId == medicationId,
      );

      if (itemIndex >= 0) {
        final item = _cartByPharmacy[pharmacyId]![itemIndex];
        if (item.quantity < item.availableStock) {
          item.quantity++;
          notifyListeners();
        } else {
          throw Exception('Stock insuffisant');
        }
      }
    }
  }

  // Diminuer la quantité d'un article
  void decrementQuantity(String pharmacyId, String medicationId) {
    if (_cartByPharmacy.containsKey(pharmacyId)) {
      final itemIndex = _cartByPharmacy[pharmacyId]!.indexWhere(
            (item) => item.medicationId == medicationId,
      );

      if (itemIndex >= 0) {
        final item = _cartByPharmacy[pharmacyId]![itemIndex];
        if (item.quantity > 1) {
          item.quantity--;
          notifyListeners();
        } else {
          // Si la quantité est 1, retirer l'article
          removeItem(pharmacyId, medicationId);
        }
      }
    }
  }

  // Vider tout le panier
  void clearCart() {
    _cartByPharmacy.clear();
    notifyListeners();
  }

  // Vider le panier d'une pharmacie spécifique
  void clearPharmacyCart(String pharmacyId) {
    _cartByPharmacy.remove(pharmacyId);
    notifyListeners();
  }

  // Obtenir le total pour une pharmacie spécifique
  double getPharmacyTotal(String pharmacyId) {
    if (!_cartByPharmacy.containsKey(pharmacyId)) return 0.0;
    return _cartByPharmacy[pharmacyId]!.fold(
      0.0,
          (sum, item) => sum + item.subtotal,
    );
  }

  // Obtenir le nombre d'articles pour une pharmacie spécifique
  int getPharmacyItemCount(String pharmacyId) {
    if (!_cartByPharmacy.containsKey(pharmacyId)) return 0;
    return _cartByPharmacy[pharmacyId]!.fold(
      0,
          (sum, item) => sum + item.quantity,
    );
  }
}