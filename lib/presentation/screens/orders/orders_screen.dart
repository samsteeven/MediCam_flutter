import 'package:flutter/material.dart';
import 'package:easypharma_flutter/data/models/order_model.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final List<Map<String, dynamic>> _orders = List.generate(
    8,
    (i) => {
      'id': 'ORD-${1000 + i}',
      'number': '#${1000 + i}',
      'status':
          i % 4 == 0
              ? 'DELIVERED'
              : (i % 4 == 1
                  ? 'IN_DELIVERY'
                  : (i % 4 == 2 ? 'PREPARING' : 'PENDING')),
      'total': (12.5 + i * 3.2),
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes commandes')),
      body: ListView.separated(
        itemBuilder: (context, index) {
          final o = _orders[index];
          final statusRaw = (o['status'] as String?) ?? '';
          final status = OrderStatus.fromString(statusRaw);
          return ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(o['number'] as String),
                Chip(
                  label: Text(
                    status.displayName,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _statusColor(status),
                ),
              ],
            ),
            subtitle: Text(
              'Total: ${(o['total'] as double).toStringAsFixed(2)} €',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/orders/details',
                arguments: {'orderId': o['id'], 'orderNumber': o['number']},
              );
            },
          );
        },
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemCount: _orders.length,
      ),
    );
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.PENDING:
        return Colors.orange;
      case OrderStatus.CONFIRMED:
      case OrderStatus.PAID:
        return Colors.blue;
      case OrderStatus.PREPARING:
        return Colors.indigo;
      case OrderStatus.READY:
        return Colors.green;
      case OrderStatus.IN_DELIVERY:
        return Colors.teal;
      case OrderStatus.DELIVERED:
        return Colors.green.shade700;
      case OrderStatus.CANCELLED:
        return Colors.red;
    }
  }
}
