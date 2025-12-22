import 'package:dio/dio.dart';
import 'package:easypharma_flutter/data/models/order_model.dart';

class OrdersRepository {
  final Dio _dio;

  OrdersRepository(this._dio);

  /// Récupérer les détails d'une commande
  /// GET /api/v1/orders/{id}
  Future<Order> getOrderDetails(String orderId) async {
    try {
      final response = await _dio.get('/api/v1/orders/$orderId');

      if (response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : response.data['data'];
        return Order.fromJson(data as Map<String, dynamic>);
      }
      throw Exception(
        'Erreur lors de la récupération de la commande: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Récupérer les commandes du patient
  /// GET /api/v1/orders/my-orders
  Future<List<Order>> getMyOrders() async {
    try {
      final response = await _dio.get('/api/v1/orders/my-orders');

      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data is List ? response.data : response.data['data'] ?? [];
        return List<Order>.from(
          data.map((json) => Order.fromJson(json as Map<String, dynamic>)),
        );
      }
      throw Exception(
        'Erreur lors de la récupération des commandes: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Récupérer les commandes d'une pharmacie (pour un pharmacien)
  /// GET /api/v1/orders/pharmacy-orders/{pharmacyId}
  Future<List<Order>> getPharmacyOrders(String pharmacyId) async {
    try {
      final response = await _dio.get(
        '/api/v1/orders/pharmacy-orders/$pharmacyId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data is List ? response.data : response.data['data'] ?? [];
        return List<Order>.from(
          data.map((json) => Order.fromJson(json as Map<String, dynamic>)),
        );
      }
      throw Exception(
        'Erreur lors de la récupération des commandes: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Créer une nouvelle commande
  /// POST /api/v1/orders
  Future<Order> createOrder(CreateOrderRequest request) async {
    try {
      final response = await _dio.post(
        '/api/v1/orders',
        data: request.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : response.data['data'];
        return Order.fromJson(data as Map<String, dynamic>);
      }
      throw Exception(
        'Erreur lors de la création de la commande: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Mettre à jour le statut d'une commande
  /// PATCH /api/v1/orders/{id}/status
  Future<Order> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final response = await _dio.patch(
        '/api/v1/orders/$orderId/status',
        data: {'status': newStatus},
      );

      if (response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : response.data['data'];
        return Order.fromJson(data as Map<String, dynamic>);
      }
      throw Exception(
        'Erreur lors de la mise à jour du statut: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }
}
