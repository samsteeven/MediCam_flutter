import 'package:flutter/foundation.dart';
import 'package:easypharma_flutter/data/models/pharmacy_model.dart';
import 'package:easypharma_flutter/data/repositories/pharmacy_inventory_repository.dart';

class PharmacyInventoryProvider extends ChangeNotifier {
  final PharmacyInventoryRepository _repository;

  // État
  Map<String, List<PharmacyMedicationInventory>> _inventories = {};
  // Key: pharmacyId, Value: list of medications

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  PharmacyInventoryProvider(this._repository);

  /// Obtenir l'inventaire d'une pharmacie
  List<PharmacyMedicationInventory>? getInventory(String pharmacyId) {
    return _inventories[pharmacyId];
  }

  /// Charger l'inventaire d'une pharmacie
  Future<void> loadInventory(String pharmacyId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final inventory = await _repository.getInventory(pharmacyId);
      _inventories[pharmacyId] = inventory;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _inventories[pharmacyId] = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ajouter un médicament à l'inventaire
  Future<void> addMedication(
    String pharmacyId,
    String medicationId,
    double price,
    int stockQuantity,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final newMedication = await _repository.addMedication(
        pharmacyId,
        medicationId,
        price,
        stockQuantity,
      );

      if (_inventories[pharmacyId] == null) {
        _inventories[pharmacyId] = [];
      }
      _inventories[pharmacyId]!.add(newMedication);
      _successMessage = 'Médicament ajouté avec succès!';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mettre à jour le stock d'un médicament
  Future<void> updateStock(
    String pharmacyId,
    String medicationId,
    int stockQuantity,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.updateStock(
        pharmacyId,
        medicationId,
        stockQuantity,
      );

      if (_inventories[pharmacyId] != null) {
        final index = _inventories[pharmacyId]!.indexWhere(
          (med) => med.medicationId == medicationId,
        );
        if (index != -1) {
          _inventories[pharmacyId]![index] = updated;
        }
      }
      _successMessage = 'Stock mis à jour avec succès!';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // APRÈS la méthode updateStock existante, on peut ajouter une méthode de déduction locale
  // pour synchroniser l'UI après une validation de commande
  void decrementLocalStock(
    String pharmacyId,
    String medicationId,
    int quantity,
  ) {
    if (_inventories[pharmacyId] != null) {
      final index = _inventories[pharmacyId]!.indexWhere(
        (m) => m.medicationId == medicationId,
      );
      if (index != -1) {
        final currentStock = _inventories[pharmacyId]![index].stockQuantity;
        // Mise à jour locale pour éviter d'attendre l'appel API complet
        _inventories[pharmacyId]![index] = _inventories[pharmacyId]![index]
            .copyWith(stockQuantity: currentStock - quantity);
        notifyListeners();
      }
    }
  }

  /// Mettre à jour le prix d'un médicament
  Future<void> updatePrice(
    String pharmacyId,
    String medicationId,
    double price,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.updatePrice(
        pharmacyId,
        medicationId,
        price,
      );

      if (_inventories[pharmacyId] != null) {
        final index = _inventories[pharmacyId]!.indexWhere(
          (med) => med.medicationId == medicationId,
        );
        if (index != -1) {
          _inventories[pharmacyId]![index] = updated;
        }
      }
      _successMessage = 'Prix mis à jour avec succès!';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Supprimer un médicament de l'inventaire
  Future<void> removeMedication(String pharmacyId, String medicationId) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repository.removeMedication(pharmacyId, medicationId);

      if (_inventories[pharmacyId] != null) {
        _inventories[pharmacyId]!.removeWhere(
          (med) => med.medicationId == medicationId,
        );
      }
      _successMessage = 'Médicament supprimé avec succès!';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Réinitialiser les messages
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Réinitialiser l'inventaire d'une pharmacie
  void clearInventory(String pharmacyId) {
    _inventories.remove(pharmacyId);
    notifyListeners();
  }
}
