import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easypharma_flutter/presentation/providers/notification_provider.dart';
import 'package:easypharma_flutter/presentation/providers/navigation_provider.dart';
import 'package:easypharma_flutter/data/models/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationCenterScreen extends StatefulWidget {
  static const String routeName = '/notifications';

  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Toujours tenter de rafraîchir les notifications à l'arrivée
      try {
        context.read<NotificationProvider>().fetchNotifications();
      } catch (e) {
        debugPrint('Error initializing notifications: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Centre de Notifications',
          style: TextStyle(
            color: Colors.blue.shade700, // Secondary Black
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.blue.shade700),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 60,
                    color: Colors.blue.shade200,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune notification',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vous n\'avez pas encore reçu de notification. Les notifications importantes (commandes, ordonnances, etc.) s\'afficheront ici.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.fetchNotifications,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
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

    return Card(
      elevation: notification.isRead ? 1 : 3,
      shadowColor: notification.isRead ? Colors.black12 : Colors.blue.shade200,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side:
            notification.isRead
                ? BorderSide.none
                : BorderSide(color: Colors.blue.shade100, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color:
                notification.isRead
                    ? Colors.grey.shade100
                    : Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getIconForType(notification.type),
            color: notification.isRead ? Colors.grey : Colors.blue.shade700,
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
    if (notification.type == 'ORDER_STATUS') {
      // Si c'est une notification de commande, on redirige vers l'historique
      // On ferme d'abord l'écran de notification
      Navigator.pop(context);

      // On change l'onglet actif vers l'historique (index 3 via NavigationProvider)
      try {
        // Le NavigationProvider est un singleton lié au haut de l'arbre, donc accessible
        // On post-frame pour éviter les conflits d'interface si besoin
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final navProvider = Provider.of<NavigationProvider>(
            context,
            listen: false,
          );
          navProvider.setIndex(3); // 3 = Historique
        });
      } catch (e) {
        debugPrint('Erreur de navigation: $e');
      }
    }
    // Ajouter d'autres cas si nécessaire
  }
}
