import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easypharma_flutter/data/models/order_model.dart';
import 'package:easypharma_flutter/presentation/providers/orders_provider.dart';
import 'package:easypharma_flutter/presentation/screens/payments/payments_screen.dart';
import 'package:easypharma_flutter/presentation/screens/payments/receipt_screen.dart';
import 'package:easypharma_flutter/core/utils/notification_helper.dart';
import 'package:easypharma_flutter/presentation/providers/review_provider.dart';
import 'package:easypharma_flutter/presentation/providers/payment_provider.dart';

class OrderDetailsScreen extends StatefulWidget {
  static const routeName = '/orders/details';
  final String? orderId;

  const OrderDetailsScreen({super.key, this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrder();
    });
  }

  void _loadOrder() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final id = widget.orderId ?? args?['orderId'] as String?;

    if (id != null) {
      context.read<OrdersProvider>().getOrderDetails(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détails commande')),
      body: Consumer<OrdersProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final order = provider.currentOrder;

          if (order == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Commande introuvable'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Retour'),
                  ),
                ],
              ),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderHeader(context, order, provider),
                  const SizedBox(height: 24),
                  _buildItemsList(order),
                  const SizedBox(height: 24),
                  _buildSummary(order),
                  const SizedBox(height: 32),
                  _buildActionButtons(context, order),
                  const SizedBox(
                    height: 16,
                  ), // Extra spacing at the very bottom
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderHeader(
    BuildContext context,
    Order order,
    OrdersProvider provider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Commande #${order.id.substring(0, 8)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status.displayName,
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.store, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pharmacie: ${provider.pharmacyNameFor(order.pharmacyId)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Date: ${order.createdAt.toString().split('.')[0]}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Articles',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: order.items.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final item = order.items[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.medication, color: Colors.blue.shade700),
              ),
              title: Text(
                item.medicationName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${item.quantity} x ${item.unitPrice.toStringAsFixed(0)} FCFA',
              ),
              trailing: Text(
                '${(item.quantity * item.unitPrice).toStringAsFixed(0)} FCFA',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummary(Order order) {
    return Card(
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sous-total', style: TextStyle(color: Colors.grey)),
                Text('${order.totalAmount} FCFA'),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total à payer',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  '${order.totalAmount} FCFA',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Order order) {
    return Column(
      children: [
        if (order.status == OrderStatus.PENDING ||
            order.status == OrderStatus.CONFIRMED)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  PaymentsScreen.routeName,
                  arguments: order,
                );
              },
              icon: const Icon(Icons.payment),
              label: const Text('Payer Maintenant'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

        if (order.status == OrderStatus.PAID ||
            order.status == OrderStatus.DELIVERED ||
            order.status == OrderStatus.IN_DELIVERY) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                // Afficher un indicateur de chargement
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder:
                      (context) =>
                          const Center(child: CircularProgressIndicator()),
                );

                try {
                  final paymentData = await context
                      .read<PaymentProvider>()
                      .fetchPaymentByOrder(order.id);
                  if (!context.mounted) return;
                  Navigator.pop(context); // Fermer loader

                  if (paymentData != null) {
                    Navigator.pushNamed(
                      context,
                      ReceiptScreen.routeName,
                      arguments: paymentData,
                    );
                  } else {
                    NotificationHelper.showError(
                      context,
                      'Impossible de récupérer les détails du paiement',
                    );
                  }
                } catch (e) {
                  if (!context.mounted) return;
                  Navigator.pop(context); // Fermer loader
                  NotificationHelper.showError(context, 'Erreur: $e');
                }
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide.none,
                backgroundColor: Colors.blue.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(Icons.receipt),
              label: const Text('Voir le reçu'),
            ),
          ),
          const SizedBox(height: 12),
        ],

        if (order.status == OrderStatus.DELIVERED)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showReviewDialog(context, order),
              style: OutlinedButton.styleFrom(
                side: BorderSide.none,
                backgroundColor: Colors.blue.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(Icons.star_border),
              label: const Text('Laisser un avis'),
            ),
          ),
      ],
    );
  }

  void _showReviewDialog(BuildContext context, Order order) {
    int selectedRating = 5;
    final commentController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Laisser un avis'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Comment s\'est passée votre commande ? Votre avis aide les autres utilisateurs.',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            index < selectedRating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () {
                            setDialogState(() => selectedRating = index + 1);
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        hintText: 'Votre commentaire...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      fixedSize: WidgetStateProperty.all(const Size(100, 50)),
                    ),
                    onPressed:
                        isLoading
                            ? null
                            : () async {
                              setDialogState(() => isLoading = true);
                              try {
                                // Assuming context.read<ReviewProvider>() is available
                                await context
                                    .read<ReviewProvider>()
                                    .submitReview(
                                      pharmacyId: order.pharmacyId,
                                      rating: selectedRating,
                                      comment: commentController.text,
                                      orderId: order.id,
                                    );

                                if (!context.mounted) return;
                                Navigator.pop(context);
                                NotificationHelper.showSuccess(
                                  context,
                                  'Merci pour votre avis !',
                                );
                              } catch (e) {
                                if (!context.mounted) return;
                                setDialogState(() => isLoading = false);
                                Navigator.pop(context);
                                NotificationHelper.showError(
                                  context,
                                  'Erreur: $e',
                                );
                              }
                            },
                    child:
                        isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.blue,
                              ),
                            )
                            : const Text('Envoyer'),
                  ),
                ],
              );
            },
          ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.PENDING:
        return Colors.orange.shade700;
      case OrderStatus.CONFIRMED:
        return Colors.blue.shade700;
      case OrderStatus.PREPARING:
        return Colors.purple.shade700;
      case OrderStatus.READY:
        return Colors.green.shade700;
      case OrderStatus.DELIVERED:
        return Colors.teal.shade700;
      case OrderStatus.PAID:
        return Colors.lightBlue.shade700;
      case OrderStatus.IN_DELIVERY:
        return Colors.teal.shade700;
      case OrderStatus.CANCELLED:
        return Colors.red.shade700;
    }
  }
}
