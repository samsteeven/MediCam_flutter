import 'package:flutter/material.dart';

class PaymentsScreen extends StatelessWidget {
  static const routeName = '/payments';

  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final payments = List.generate(
      6,
      (i) => {
        'id': 'P-${i + 1}',
        'amount': 10.0 + i * 5,
        'status': i.isEven ? 'PAID' : 'PENDING',
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Paiements')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: payments.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, i) {
          final p = payments[i];
          final id = p['id'] as String;
          final amount = p['amount'] as double;
          final status = p['status'] as String;

          return ListTile(
            title: Text(id),
            subtitle: Text('Montant: ${amount.toStringAsFixed(2)} €'),
            trailing: Text(status),
            onTap:
                () => showDialog(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        title: Text(id),
                        content: Text(
                          'Statut: $status\nMontant: ${amount.toStringAsFixed(2)} €',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Fermer'),
                          ),
                        ],
                      ),
                ),
          );
        },
      ),
    );
  }
}
