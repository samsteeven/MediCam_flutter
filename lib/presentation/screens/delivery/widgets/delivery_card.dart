import 'package:flutter/material.dart';
import 'package:easypharma_flutter/data/models/delivery_model.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryCard extends StatelessWidget {
  final Delivery delivery;
  final VoidCallback? onAccept;
  final VoidCallback? onConfirm;

  const DeliveryCard({
    super.key,
    required this.delivery,
    this.onAccept,
    this.onConfirm,
  });

  Color _getStatusColor(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.PENDING:
        return Colors.orange;
      case DeliveryStatus.ASSIGNED:
        return Colors.blue;
      case DeliveryStatus.PICKED_UP:
        return Colors.purple;
      case DeliveryStatus.DELIVERED:
        return Colors.green;
      case DeliveryStatus.FAILED:
        return Colors.red;
      case DeliveryStatus.CANCELLED:
        return Colors.grey;
    }
  }

  Future<void> _openMap() async {
    if (delivery.deliveryLatitude != null &&
        delivery.deliveryLongitude != null) {
      final googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${delivery.deliveryLatitude},${delivery.deliveryLongitude}',
      );
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      }
    } else if (delivery.deliveryAddress != null) {
      final query = Uri.encodeComponent(delivery.deliveryAddress!);
      final googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$query',
      );
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(delivery.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(delivery.status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    delivery.status.displayName,
                    style: TextStyle(
                      color: _getStatusColor(delivery.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (delivery.distance != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${delivery.distance!.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        delivery.customerName ?? 'Client inconnu',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        delivery.customerPhone ?? 'Pas de numéro',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.phone, color: Colors.green),
                  onPressed: () {
                    if (delivery.customerPhone != null) {
                      launchUrl(Uri.parse('tel:${delivery.customerPhone}'));
                    }
                  },
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.home_outlined, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    delivery.deliveryAddress ?? 'Adresse inconnue',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openMap,
                    icon: const Icon(Icons.map),
                    label: const Text('GPS'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (delivery.status == DeliveryStatus.ASSIGNED &&
                    onAccept != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onAccept,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Démarrer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                if (delivery.status == DeliveryStatus.PICKED_UP &&
                    onConfirm != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onConfirm,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Livrer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
