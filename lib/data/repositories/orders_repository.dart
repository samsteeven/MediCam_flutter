import 'package:dio/dio.dart';
import 'package:easypharma_flutter/data/models/order_model.dart';
import 'package:easypharma_flutter/core/constants/api_constants.dart';

class OrdersRepository {
  final Dio _dio;

  OrdersRepository(this._dio);

  /// Récupérer les détails d'une commande
  /// GET /api/v1/orders/{id}
  Future<Order> getOrderDetails(String orderId) async {
    try {
      final response = await _dio.get(ApiConstants.orderById(orderId));

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
      final response = await _dio.get(ApiConstants.myOrders);

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
      final response = await _dio.get(ApiConstants.pharmacyOrders(pharmacyId));

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
        ApiConstants.orders,
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
        ApiConstants.orderStatus(orderId),
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

  Future<void> updateDeliveryLocation(
    String deliveryId,
    double lat,
    double lon,
  ) async {
    await _dio.patch(
      ApiConstants.deliveryLocation(deliveryId),
      data: {'latitude': lat, 'longitude': lon},
    );
  }

  /// Récupérer les statistiques de revenus d'une pharmacie
  /// GET /api/v1/orders/pharmacy-stats/{pharmacyId}
  Future<Map<String, dynamic>> getPharmacyStats(String pharmacyId) async {
    try {
      final response = await _dio.get(ApiConstants.pharmacyStats(pharmacyId));
      if (response.statusCode == 200) {
        return response.data is Map
            ? response.data
            : response.data['data'] ?? {};
      }
      throw Exception(
        'Erreur lors de la récupération des stats: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }
}
