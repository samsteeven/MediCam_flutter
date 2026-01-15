import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatelessWidget {
  static const routeName = '/orders/details';
  final String? orderId;

  const OrderDetailsScreen({super.key, this.orderId});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final id = orderId ?? args?['orderId'] as String?;
    final number = args?['orderNumber'] as String?;

    return Scaffold(
      appBar: AppBar(title: const Text('Détails commande')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Commande: ${number ?? id ?? '-'}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            const Text('Statut: En cours'),
            const SizedBox(height: 8),
            const Text('Montant: 24.90 €'),
            const SizedBox(height: 16),
            const Text('Articles:'),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    title: Text('Paracétamol 500mg'),
                    subtitle: Text('x1'),
                  ),
                  ListTile(
                    title: Text('Vitamine C 1000mg'),
                    subtitle: Text('x2'),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Suivre la commande (placeholder)'),
                      ),
                    );
                  },
                  child: const Text('Suivre'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Retour'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
