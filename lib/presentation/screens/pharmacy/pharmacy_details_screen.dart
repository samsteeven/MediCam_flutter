import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easypharma_flutter/data/models/pharmacy_model.dart';
import 'package:easypharma_flutter/presentation/providers/medication_provider.dart';
import 'package:easypharma_flutter/presentation/providers/pharmacies_provider.dart';
import 'package:easypharma_flutter/presentation/providers/cart_provider.dart';
import 'package:easypharma_flutter/presentation/screens/pharmacy/pharmacy_reviews_screen.dart';
import 'package:easypharma_flutter/core/utils/notification_helper.dart';
import 'package:easypharma_flutter/presentation/providers/navigation_provider.dart';

class PharmacyDetailsScreen extends StatefulWidget {
  static const routeName = '/pharmacy';
  final String? pharmacyId;

  const PharmacyDetailsScreen({super.key, this.pharmacyId});

  @override
  State<PharmacyDetailsScreen> createState() => _PharmacyDetailsScreenState();
}

class _PharmacyDetailsScreenState extends State<PharmacyDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final pharmacyId = widget.pharmacyId ?? args?['pharmacyId'] as String?;

    if (pharmacyId != null) {
      context.read<PharmaciesProvider>().selectPharmacyById(pharmacyId);
      context.read<MedicationProvider>().fetchPharmacyInventory(pharmacyId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<PharmaciesProvider, MedicationProvider>(
        builder: (context, pharmProvider, medProvider, child) {
          if (pharmProvider.isLoading &&
              pharmProvider.selectedPharmacy == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final pharmacy = pharmProvider.selectedPharmacy;
          if (pharmacy == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Pharmacie')),
              body: const Center(child: Text('Pharmacie non trouvée')),
            );
          }

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, pharmacy),
              SliverToBoxAdapter(child: _buildPharmacyInfo(context, pharmacy)),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    'Médicaments disponibles',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              if (medProvider.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (medProvider.pharmacyInventory.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: Text('Aucun médicament disponible')),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final pm = medProvider.pharmacyInventory[index];
                      return _buildMedicationItem(context, pm);
                    }, childCount: medProvider.pharmacyInventory.length),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Pharmacy pharmacy) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          pharmacy.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade300, Colors.blue.shade700],
            ),
          ),
          child: const Icon(
            Icons.local_pharmacy,
            size: 80,
            color: Colors.white24,
          ),
        ),
      ),
    );
  }

  Widget _buildPharmacyInfo(BuildContext context, Pharmacy pharmacy) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pharmacy.address,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pharmacy.city,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                if (pharmacy.averageRating > 0)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => PharmacyReviewsScreen(
                                pharmacyId: pharmacy.id,
                                pharmacyName: pharmacy.name,
                              ),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              double starRating = index + 1.0;
                              IconData icon;
                              if (pharmacy.averageRating >= starRating) {
                                icon = Icons.star;
                              } else if (pharmacy.averageRating >=
                                  starRating - 0.5) {
                                icon = Icons.star_half;
                              } else {
                                icon = Icons.star_border;
                              }
                              return Icon(icon, color: Colors.amber, size: 16);
                            }),
                            const SizedBox(width: 8),
                            Text(
                              pharmacy.averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${pharmacy.ratingCount} avis',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.phone, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(pharmacy.phone),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    // Action appel
                  },
                  icon: const Icon(Icons.call),
                  label: const Text('Appeler'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationItem(BuildContext context, dynamic pm) {
    final med = pm.medication;
    final isOutOfStock = pm.stockQuantity <= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.medication, color: Colors.blue.shade700),
        ),
        title: Text(
          med.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              med.description ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${pm.price} FCFA',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isOutOfStock
                            ? Colors.red.shade50
                            : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isOutOfStock ? 'Rupture' : 'Stock: ${pm.stockQuantity}',
                    style: TextStyle(
                      color: isOutOfStock ? Colors.red : Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.add_shopping_cart,
            color: isOutOfStock ? Colors.grey : Colors.blue.shade700,
          ),
          onPressed:
              isOutOfStock
                  ? null
                  : () {
                    context.read<CartProvider>().addItem(
                      med,
                      pm.pharmacy,
                      pm.price,
                    );
                    NotificationHelper.showSuccess(
                      context,
                      '${med.name} ajouté au panier',
                      onTap: () {
                        context.read<NavigationProvider>().setIndex(2);
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                    );
                  },
        ),
      ),
    );
  }
}
