import 'package:flutter/material.dart';

class MedicationDetailsScreen extends StatelessWidget {
  static const routeName = '/medication';
  final String? medicationId;

  const MedicationDetailsScreen({super.key, this.medicationId});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final id = medicationId ?? args?['medicationId'] as String? ?? 'M-1';
    final name = args?['name'] as String? ?? 'Médicament inconnu';
    final price = args?['price'] as double? ?? 4.5;

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Référence: $id'),
            const SizedBox(height: 8),
            Text('Prix: ${price.toStringAsFixed(2)} €'),
            const SizedBox(height: 16),
            const Text('Description:'),
            const SizedBox(height: 8),
            const Text('Description détaillée du médicament (placeholder).'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ajouté au panier (placeholder)'),
                    ),
                  );
                },
                child: const Text('Ajouter au panier'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
