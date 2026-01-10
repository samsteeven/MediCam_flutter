import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:easypharma_flutter/core/utils/notification_permissions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easypharma_flutter/data/models/notification_model.dart';
import 'package:easypharma_flutter/data/repositories/notification_repository.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationRepository _repository;
  final SharedPreferences _prefs;

  List<NotificationDTO> _notifications = [];
  bool _isLoading = false;
  Timer? _pollingTimer;
  int _unreadCount = 0;
  final _alertController = StreamController<String>.broadcast();
  Stream<String> get alertStream => _alertController.stream;

  NotificationProvider(this._repository, this._prefs);

  /// Initialize notifications - should be called after authentication
  Future<void> initialize() async {
    // Charger les notifications locales persistées avant fetch serveur
    await _loadLocalNotifications();

    // Demander l'autorisation de notifications (web / iOS / Android)
    try {
      final granted = await requestNotificationPermission();
      if (!granted) {
        debugPrint('Notifications permission not granted');
        // still continue to fetch server notifications (read-only)
      }
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
    }

    await fetchNotifications();
    startPolling();
  }

  Future<void> _loadLocalNotifications() async {
    try {
      final raw = _prefs.getString('local_notifications');
      if (raw == null || raw.isEmpty) return;
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      final local =
          list
              .map((e) => NotificationDTO.fromJson(e as Map<String, dynamic>))
              .toList();

      // Prepend local notifications to in-memory list
      _notifications = [
        ...local,
        ..._notifications.where((n) => !n.id.startsWith('local-')),
      ];
      _unreadCount = _notifications.where((n) => !n.isRead).length;
    } catch (e) {
      debugPrint('Error loading local notifications: $e');
    }
  }

  Future<void> _saveLocalNotifications() async {
    try {
      final local =
          _notifications
              .where((n) => n.id.startsWith('local-'))
              .map((n) => n.toJson())
              .toList();
      await _prefs.setString('local_notifications', jsonEncode(local));
    } catch (e) {
      debugPrint('Error saving local notifications: $e');
    }
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

      // Conserver les notifications locales (créées côté client) afin qu'elles
      // ne soient pas écrasées par un fetch serveur vide.
      final localNotifications =
          _notifications.where((n) => n.id.startsWith('local-')).toList();

      // Dédupliquer en comparant les IDs bruts (sans le préfixe 'local-').
      // Si une notification locale a pour id 'local-123' et que le serveur
      // renvoie '123', on considère que c'est la même notification et on garde
      // la version locale (pour éviter de l'écraser), sauf si le serveur fournit
      // une version plus récente (rare pour les locales).
      final localRawIds =
          localNotifications
              .map((n) => n.id.replaceFirst('local-', ''))
              .toSet();

      final merged = <NotificationDTO>[];
      // Garder les locales en tête
      merged.addAll(localNotifications);

      // Ajouter les notifications serveur dont l'id brut n'est pas déjà local
      for (final srv in newNotifications) {
        final rawId = srv.id;
        if (!localRawIds.contains(rawId)) {
          merged.add(srv);
        }
      }

      // Calculer les unread avant et après
      final int previousUnread = _unreadCount;
      final int newUnread = merged.where((n) => !n.isRead).length;

      // Si le nombre de notifications non lues a augmenté, émettre une alerte
      if (newUnread > previousUnread) {
        _showLocalAlert();
      }

      // Mettre à jour la liste et le compteur
      _notifications = merged;
      _unreadCount = newUnread;
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
      // If this is a local notification (client-only), mark locally only.
      if (id.startsWith('local-')) {
        final index = _notifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
          _unreadCount = _notifications.where((n) => !n.isRead).length;
          _saveLocalNotifications();
          notifyListeners();
        }
        return;
      }

      // For server notifications, call API then update local state.
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

  /// Add a notification locally (useful when server does not create it yet)
  void addLocalNotification(NotificationDTO notification) {
    // Ensure local notifications have a distinctive id prefix
    var toAdd = notification;
    if (!toAdd.id.startsWith('local-')) {
      toAdd = toAdd.copyWith(id: 'local-${toAdd.id}');
    }

    _notifications.removeWhere((n) => n.id == toAdd.id);
    _notifications.insert(0, toAdd);
    if (!toAdd.isRead) {
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      _showLocalAlert();
    }
    // Persist local notifications
    _saveLocalNotifications();
    notifyListeners();
  }

  @override
  void dispose() {
    stopPolling();
    _alertController.close();
    super.dispose();
  }
}
