import 'package:dio/dio.dart';
import 'package:easypharma_flutter/core/constants/api_constants.dart';
import 'package:easypharma_flutter/data/models/notification_model.dart';

class NotificationRepository {
  final Dio _dio;

  NotificationRepository(this._dio);

  Future<List<NotificationDTO>> fetchMyNotifications() async {
    try {
      final response = await _dio.get(ApiConstants.myNotifications);
      if (response.statusCode == 200) {
        final dynamic rawData = response.data;
        final List<dynamic> data =
            (rawData is List)
                ? rawData
                : (rawData is Map && rawData.containsKey('data'))
                ? rawData['data']
                : [];
        return data
            .map(
              (json) => NotificationDTO.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _dio.patch(ApiConstants.markNotificationAsRead(notificationId));
    } catch (e) {
      rethrow;
    }
  }
}
