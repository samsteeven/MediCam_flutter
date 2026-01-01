import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easypharma_flutter/presentation/providers/notification_provider.dart';
import 'package:easypharma_flutter/data/models/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationCenterScreen extends StatelessWidget {
  static const String routeName = '/notifications';

  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Centre de Notifications')),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.notifications.isEmpty) {
            return const Center(
              child: Text('Aucune notification pour le moment.'),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.fetchNotifications,
            child: ListView.separated(
              itemCount: provider.notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = provider.notifications[index];
                return _NotificationItem(notification: notification);
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationDTO notification;

  const _NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<NotificationProvider>();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      color: notification.isRead ? null : Colors.blue.withOpacity(0.05),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              notification.isRead ? Colors.grey[200] : Colors.blue[100],
          child: Icon(
            _getIconForType(notification.type),
            color: notification.isRead ? Colors.grey : Colors.blue,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.message),
            const SizedBox(height: 4),
            Text(
              dateFormat.format(notification.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing:
            !notification.isRead
                ? Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                )
                : null,
        onTap: () {
          if (!notification.isRead) {
            provider.markAsRead(notification.id);
          }
          _handleNavigation(context, notification);
        },
      ),
    );
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'ORDER_STATUS':
        return Icons.shopping_bag;
      case 'DELIVERY_ASSIGNED':
        return Icons.local_shipping;
      case 'PROMOTION':
        return Icons.local_offer;
      default:
        return Icons.notifications;
    }
  }

  void _handleNavigation(BuildContext context, NotificationDTO notification) {
    // Exemple de navigation selon le type et le referenceId
    if (notification.type == 'ORDER_STATUS' &&
        notification.referenceId != null) {
      // Navigator.pushNamed(context, '/order-details', arguments: notification.referenceId);
    }
  }
}
