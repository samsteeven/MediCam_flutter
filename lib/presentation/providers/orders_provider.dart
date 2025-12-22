import 'package:flutter/foundation.dart';
import 'package:easypharma_flutter/data/models/order_model.dart';
import 'package:easypharma_flutter/data/repositories/orders_repository.dart';

class OrdersProvider extends ChangeNotifier {
  final OrdersRepository _repository;

  // État
  List<Order> _myOrders = [];
  List<Order> _pharmacyOrders = [];
  Order? _currentOrder;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Getters
  List<Order> get myOrders => _myOrders;
  List<Order> get pharmacyOrders => _pharmacyOrders;
  Order? get currentOrder => _currentOrder;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  OrdersProvider(this._repository);

  /// Récupérer les détails d'une commande
  Future<void> getOrderDetails(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentOrder = await _repository.getOrderDetails(orderId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _currentOrder = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Récupérer les commandes du patient
  Future<void> fetchMyOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _myOrders = await _repository.getMyOrders();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _myOrders = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Récupérer les commandes d'une pharmacie
  Future<void> fetchPharmacyOrders(String pharmacyId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pharmacyOrders = await _repository.getPharmacyOrders(pharmacyId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _pharmacyOrders = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Créer une nouvelle commande
  Future<void> createOrder(CreateOrderRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final newOrder = await _repository.createOrder(request);
      _currentOrder = newOrder;
      _successMessage = 'Commande créée avec succès!';
      // Rafraîchir la liste des commandes
      await fetchMyOrders();
    } catch (e) {
      _errorMessage = e.toString();
      _currentOrder = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mettre à jour le statut d'une commande
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final updatedOrder = await _repository.updateOrderStatus(
        orderId,
        newStatus,
      );
      _currentOrder = updatedOrder;

      // Mettre à jour dans les listes
      final index = _myOrders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _myOrders[index] = updatedOrder;
      }

      final pharmacyIndex = _pharmacyOrders.indexWhere(
        (order) => order.id == orderId,
      );
      if (pharmacyIndex != -1) {
        _pharmacyOrders[pharmacyIndex] = updatedOrder;
      }

      _successMessage = 'Statut mis à jour avec succès!';
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
}
