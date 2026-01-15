import 'package:flutter/material.dart';

class CheckoutScreen extends StatelessWidget {
  static const routeName = '/checkout';

  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final items = args?['items'] as List<dynamic>?;

    final total =
        items == null
            ? 0.0
            : items.fold(
              0.0,
              (s, e) => s + (e['price'] as double) * (e['qty'] as int),
            );

    return Scaffold(
      appBar: AppBar(title: const Text('Paiement')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Récapitulatif',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child:
                  items == null
                      ? const Center(
                        child: Text('Aucun article dans le panier'),
                      )
                      : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, i) {
                          final it = items[i];
                          return ListTile(
                            title: Text(it['name']),
                            trailing: Text(
                              '${it['qty']} x ${it['price'].toStringAsFixed(2)} €',
                            ),
                          );
                        },
                      ),
            ),
            Text(
              'Total: ${total.toStringAsFixed(2)} €',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Paiement simulé (placeholder)'),
                    ),
                  );
                },
                child: const Text('Payer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
