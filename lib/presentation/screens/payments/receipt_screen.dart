import 'package:flutter/material.dart';

class ReceiptScreen extends StatelessWidget {
  static const routeName = '/receipt';
  final Map<String, dynamic> paymentData;

  const ReceiptScreen({super.key, required this.paymentData});

  @override
  Widget build(BuildContext context) {
    final data = paymentData;
    final amount = data['amount'] ?? 0.0;
    final rawDate =
        data['paidAt'] ?? data['createdAt'] ?? DateTime.now().toString();
    final date = rawDate.toString().split('T').first;
    final method = data['paymentMethod'] ?? data['method'] ?? 'N/A';
    final transactionId = data['transactionId'] ?? data['id'] ?? 'N/A';

    return Scaffold(
      appBar: AppBar(title: const Text('Reçu de Paiement')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Paiement Réussi',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Divider(height: 32),
                _buildRow('Transaction ID', transactionId.toString()),
                _buildRow('Date', date),
                _buildRow('Méthode', method.toString().replaceAll('_', ' ')),
                if (data['phoneNumber'] != null || data['phone'] != null)
                  _buildRow(
                    'Numéro utilisé',
                    (data['phoneNumber'] ?? data['phone']).toString(),
                  ),
                const Divider(height: 32),
                _buildRow(
                  'Montant Total',
                  '${amount} FCFA',
                  isBold: true,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.delivery_dining, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Votre commande est en attente de livraison.',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    // Retour à l'accueil
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/patient-home',
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Retour à l\'accueil'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: isBold ? 18 : 16,
                color: color ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
