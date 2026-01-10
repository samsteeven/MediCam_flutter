import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easypharma_flutter/data/models/delivery_model.dart';
import 'package:easypharma_flutter/presentation/providers/delivery_provider.dart';
import 'package:easypharma_flutter/presentation/screens/delivery/delivery_confirmation_screen.dart';
import 'package:intl/intl.dart';

class DeliveryCard extends StatelessWidget {
  final Delivery delivery;

  const DeliveryCard({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(delivery.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Livraison #${delivery.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    delivery.status.displayName,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    delivery.order?.pharmacyId ?? 'Pharmacie locale',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 20, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  delivery.assignedAt != null
                      ? DateFormat('dd MMM, HH:mm').format(delivery.assignedAt!)
                      : 'Non assignée',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    if (delivery.status == DeliveryStatus.DELIVERED ||
        delivery.status == DeliveryStatus.CANCELLED) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (delivery.status == DeliveryStatus.ASSIGNED)
          Expanded(
            child: ElevatedButton(
              onPressed:
                  () => context.read<DeliveryProvider>().updateDeliveryStatus(
                    delivery.id,
                    DeliveryStatus.PICKED_UP,
                  ),
              style: ElevatedButton.styleFrom(),
              child: const Text(
                'Récupérer le colis',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        if (delivery.status == DeliveryStatus.PICKED_UP)
          Expanded(
            child: ElevatedButton(
              onPressed:
                  () => context.read<DeliveryProvider>().updateDeliveryStatus(
                    delivery.id,
                    DeliveryStatus.IN_TRANSIT,
                  ),
              style: ElevatedButton.styleFrom(),
              child: const Text(
                'Lancer la livraison',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        if (delivery.status == DeliveryStatus.IN_TRANSIT)
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            DeliveryConfirmationScreen(delivery: delivery),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(),
              child: const Text(
                'Confirmer la livraison',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Color _getStatusColor(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.PENDING:
        return Colors.grey;
      case DeliveryStatus.ASSIGNED:
        return Colors.blue;
      case DeliveryStatus.PICKED_UP:
        return Colors.orange;
      case DeliveryStatus.IN_TRANSIT:
        return Colors.amber.shade700;
      case DeliveryStatus.DELIVERED:
        return Colors.green;
      case DeliveryStatus.CANCELLED:
        return Colors.red;
    }
  }
}
