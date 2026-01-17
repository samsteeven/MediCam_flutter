import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easypharma_flutter/data/models/medication_model.dart';

import 'package:easypharma_flutter/presentation/providers/cart_provider.dart';
import 'package:easypharma_flutter/core/utils/notification_helper.dart';

class MedicationDetailsScreen extends StatelessWidget {
  static const routeName = '/medication';
  final PharmacyMedication? pharmacyMedication;

  const MedicationDetailsScreen({super.key, this.pharmacyMedication});

  @override
  Widget build(BuildContext context) {
    // Récupérer les arguments si passés par la route
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    PharmacyMedication? pm = pharmacyMedication;

    // Si pas passé directement, essayer de reconstruire ou récupérer depuis args
    if (pm == null && args != null) {
      if (args['pharmacyMedication'] is PharmacyMedication) {
        pm = args['pharmacyMedication'] as PharmacyMedication;
      }
      // Note: Idéalement on devrait pouvoir fetcher par ID si manquants,
      // mais ici on suppose qu'on vient de la recherche.
    }

    if (pm == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détails médicament')),
        body: const Center(child: Text('Médicament introuvable')),
      );
    }

    final med = pm.medication;
    final pharmacy = pm.pharmacy;
    final price = pm.price;
    final isOutOfStock = pm.stockQuantity <= 0;

    return Scaffold(
      appBar: AppBar(title: Text(med.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec nom et classe
            Text(
              med.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (med.genericName != null && med.genericName!.isNotEmpty)
              Text(
                '(${med.genericName})',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                med.therapeuticClass.displayName,
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Infos Pharmacie
            _buildSectionTitle('Pharmacie'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.local_pharmacy, color: Colors.green),
                title: Text(
                  pharmacy.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${pharmacy.address}, ${pharmacy.city}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${pharmacy.averageRating.toStringAsFixed(1)} (${pharmacy.ratingCount} avis)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  // Aller à la page de la pharmacie
                  Navigator.pushNamed(
                    context,
                    '/pharmacy',
                    arguments: {
                      'pharmacyId': pharmacy.id,
                      'name': pharmacy.name,
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Prix et Stock
            _buildSectionTitle('Offre'),
            Card(
              elevation: 0,
              color: Colors.grey.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Prix unitaire',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${pm.price} FCFA',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Disponibilité',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isOutOfStock ? 'Rupture de stock' : 'En stock',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isOutOfStock ? Colors.red : Colors.green,
                          ),
                        ),
                        if (!isOutOfStock)
                          Text(
                            '${pm.stockQuantity} disponibles',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Description
            if (med.description != null && med.description!.isNotEmpty) ...[
              _buildSectionTitle('Description'),
              Text(
                med.description!,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 24),
            ],

            // Ordonnance requise
            if (med.requiresPrescription)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Ce médicament nécessite une ordonnance médicale.',
                        style: TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Espace pour le bouton
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed:
                isOutOfStock
                    ? null
                    : () {
                      final price = pm?.price ?? 0.0;
                      context.read<CartProvider>().addItem(
                        med,
                        pharmacy,
                        price,
                      );
                      NotificationHelper.showSuccess(
                        context,
                        '${med.name} ajouté au panier',
                        onTap: () {
                          Navigator.pop(context); // fermer détails
                          Navigator.pushNamed(
                            context,
                            '/',
                          ); // retour home (si besoin)
                          // Idéalement changer index tab mais context ici est screen
                        },
                      );
                    },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue.shade700,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isOutOfStock ? 'Indisponible' : 'Ajouter au panier',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }
}
