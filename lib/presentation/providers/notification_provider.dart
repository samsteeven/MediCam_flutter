import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:easypharma_flutter/data/models/notification_model.dart';
import 'package:easypharma_flutter/data/repositories/notification_repository.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationRepository _repository;

  List<NotificationDTO> _notifications = [];
  bool _isLoading = false;
  Timer? _pollingTimer;
  int _unreadCount = 0;
  final _alertController = StreamController<String>.broadcast();
  Stream<String> get alertStream => _alertController.stream;

  NotificationProvider(this._repository);

  /// Initialize notifications - should be called after authentication
  void initialize() {
    fetchNotifications();
    startPolling();
  }

  List<NotificationDTO> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;

  Future<void> fetchNotifications({bool background = false}) async {
    if (!background) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final newNotifications = await _repository.fetchMyNotifications();

      // Trier par date décroissante
      newNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Vérifier s'il y a de nouvelles notifications pour l'alerte
      // Simple vérification par count pour l'instant
      if (_notifications.isNotEmpty &&
          newNotifications.length > _notifications.length) {
        _showLocalAlert();
      }

      _notifications = newNotifications;
      _unreadCount = _notifications.where((n) => !n.isRead).length;
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      if (!background) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      fetchNotifications(background: true);
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
  }

  void _showLocalAlert() {
    _alertController.add('Vous avez de nouvelles notifications');
  }

  @override
  void dispose() {
    stopPolling();
    _alertController.close();
    super.dispose();
  }
}
