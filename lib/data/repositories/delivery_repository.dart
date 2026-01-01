import 'package:dio/dio.dart';
import 'package:easypharma_flutter/core/constants/api_constants.dart';
import 'package:easypharma_flutter/data/models/delivery_model.dart';

class DeliveryRepository {
  final Dio _dio;

  DeliveryRepository(this._dio);

  Future<DeliveryStats> getMyStats() async {
    try {
      final response = await _dio.get(ApiConstants.myDeliveryStats);
      if (response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : response.data['data'];
        return DeliveryStats.fromJson(data as Map<String, dynamic>);
      }
      throw Exception('Failed to load stats');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<List<Delivery>> getMyDeliveries() async {
    try {
      final response = await _dio.get(ApiConstants.myDeliveries);
      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data is List ? response.data : response.data['data'] ?? [];
        return data
            .map((json) => Delivery.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load deliveries');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<List<Delivery>> getOngoingDeliveries() async {
    try {
      final response = await _dio.get(ApiConstants.ongoingDeliveries);
      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data is List ? response.data : response.data['data'] ?? [];
        return data
            .map((json) => Delivery.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load ongoing deliveries');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<Delivery> updateStatus(String deliveryId, String status) async {
    try {
      final response = await _dio.patch(
        ApiConstants.deliveryStatus(deliveryId),
        queryParameters: {'status': status},
      );
      if (response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : response.data['data'];
        return Delivery.fromJson(data as Map<String, dynamic>);
      }
      throw Exception('Failed to update status');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<void> updateLocation(
    String deliveryId,
    double startLat,
    double startLon,
  ) async {
    try {
      await _dio.patch(
        ApiConstants.deliveryLocation(deliveryId),
        queryParameters: {'latitude': startLat, 'longitude': startLon},
      );
    } on DioException catch (e) {
      // Location updates might fail silently or we just log it
      print('Location update failed: ${e.message}');
    }
  }

  Future<Delivery> submitProof(String deliveryId, String proofUrl) async {
    try {
      final response = await _dio.patch(
        ApiConstants.deliveryProof(deliveryId),
        queryParameters: {'proofUrl': proofUrl},
      );
      if (response.statusCode == 200) {
        final data =
            response.data is Map ? response.data : response.data['data'];
        return Delivery.fromJson(data as Map<String, dynamic>);
      }
      throw Exception('Failed to submit proof');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<void> assignDelivery(String orderId) async {
    try {
      await _dio.post(ApiConstants.assignDelivery, data: {'orderId': orderId});
    } on DioException catch (e) {
      throw Exception('Failed to assign delivery: ${e.message}');
    }
  }
}
