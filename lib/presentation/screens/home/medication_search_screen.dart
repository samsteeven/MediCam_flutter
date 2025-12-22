import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easypharma_flutter/data/models/medication_model.dart';
import 'package:easypharma_flutter/presentation/providers/medication_provider.dart';

class MedicationSearchScreen extends StatefulWidget {
  const MedicationSearchScreen({super.key});

  @override
  State<MedicationSearchScreen> createState() => _MedicationSearchScreenState();
}

class _MedicationSearchScreenState extends State<MedicationSearchScreen> {
  late TextEditingController _searchController;
  TherapeuticClass? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Rechercher un médicament',
          style: TextStyle(
            color: Colors.blue.shade700,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue.shade700),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<MedicationProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Champ de recherche
                _buildSearchField(context, provider),
                const SizedBox(height: 20),

                // Filtres
                _buildCategoryFilter(context, provider),
                const SizedBox(height: 20),

                // Options de tri
                _buildSortOptions(context, provider),
                const SizedBox(height: 28),

                // Résultats
                if (provider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (provider.errorMessage != null)
                  _buildErrorWidget(provider.errorMessage!)
                else if (provider.searchResults.isEmpty &&
                    _searchController.text.isNotEmpty)
                  _buildNoResultsWidget()
                else if (provider.searchResults.isEmpty)
                  _buildEmptyStateWidget()
                else
                  _buildSearchResultsList(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchField(BuildContext context, MedicationProvider provider) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Rechercher un médicament...',
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(Icons.search_outlined, color: Colors.blue.shade600),
        suffixIcon:
            _searchController.text.isNotEmpty
                ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.blue.shade600),
                  onPressed: () {
                    _searchController.clear();
                    provider.clearResults();
                    setState(() {});
                  },
                )
                : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      onChanged: (value) {
        setState(() {});
        if (value.length > 2) {
          provider.searchMedications(
            value,
            therapeuticClass: _selectedCategory,
          );
        }
      },
      onSubmitted: (value) {
        if (value.isNotEmpty) {
          provider.searchMedications(
            value,
            therapeuticClass: _selectedCategory,
          );
        }
      },
    );
  }

  Widget _buildCategoryFilter(
    BuildContext context,
    MedicationProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Catégorie thérapeutique',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryChip('Tous', null, provider),
              ...TherapeuticClass.values
                  .map(
                    (category) => _buildCategoryChip(
                      category.displayName,
                      category,
                      provider,
                    ),
                  )
                  .toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(
    String label,
    TherapeuticClass? category,
    MedicationProvider provider,
  ) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade800,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
          if (_searchController.text.isNotEmpty) {
            provider.searchMedications(
              _searchController.text,
              therapeuticClass: _selectedCategory,
            );
          }
        },
        backgroundColor: Colors.white,
        selectedColor: Colors.blue.shade50,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: isSelected ? Colors.blue.shade100 : Colors.grey.shade200,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildSortOptions(BuildContext context, MedicationProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Trier par:', style: TextStyle(fontWeight: FontWeight.w600)),
        DropdownButton<String>(
          value: provider.sortBy,
          items: const [
            DropdownMenuItem(value: 'name', child: Text('Nom')),
            DropdownMenuItem(value: 'price', child: Text('Prix')),
          ],
          onChanged: (value) {
            if (value != null) {
              provider.setSortBy(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildSearchResultsList(
    BuildContext context,
    MedicationProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${provider.searchResults.length} résultat(s)',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.searchResults.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final medication = provider.searchResults[index];
            return _buildMedicationCard(context, medication, provider);
          },
        ),
      ],
    );
  }

  Widget _buildMedicationCard(
    BuildContext context,
    Medication medication,
    MedicationProvider provider,
  ) {
    return GestureDetector(
      onTap: () {
        provider.getPricesForMedication(medication.id);
        _showMedicationDetails(context, medication, provider);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade50.withOpacity(0.6),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              medication.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (medication.genericName != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '(${medication.genericName})',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getCategoryColor(
                  medication.therapeuticClass,
                ).withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                medication.therapeuticClass.displayName,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            if (medication.description != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  medication.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showMedicationDetails(
    BuildContext context,
    Medication medication,
    MedicationProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Consumer<MedicationProvider>(
              builder: (context, medicationProvider, _) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        medication.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      if (medication.genericName != null)
                        Text(
                          'Générique: ${medication.genericName}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      const SizedBox(height: 16),
                      Chip(
                        label: Text(medication.therapeuticClass.displayName),
                        backgroundColor: _getCategoryColor(
                          medication.therapeuticClass,
                        ),
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                      if (medication.description != null) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(medication.description!),
                      ],
                      const SizedBox(height: 24),
                      const Text(
                        'Prix dans les pharmacies',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (medicationProvider.isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (medicationProvider.priceResults.isEmpty)
                        const Text(
                          'Aucune pharmacie disponible',
                          style: TextStyle(color: Colors.grey),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: medicationProvider.priceResults.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final price =
                                medicationProvider.priceResults[index];
                            return _buildPharmacyPriceCard(price);
                          },
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPharmacyPriceCard(PharmacyMedication pharmacyMedication) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade50.withOpacity(0.6),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pharmacyMedication.pharmacy.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            pharmacyMedication.pharmacy.address,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Prix: ${pharmacyMedication.price.toStringAsFixed(2)} FCFA',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.green,
                ),
              ),
              Text(
                'Stock: ${pharmacyMedication.quantityInStock}',
                style: TextStyle(
                  fontSize: 12,
                  color:
                      pharmacyMedication.quantityInStock > 0
                          ? Colors.green
                          : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Ajouté au panier de ${pharmacyMedication.pharmacy.name}',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
              ),
              child: const Text('Ajouter au panier'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Erreur',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Aucun médicament trouvé',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Essayez une autre recherche',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_pharmacy, size: 48, color: Colors.blue),
          const SizedBox(height: 16),
          const Text(
            'Rechercher un médicament',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Entrez au moins 3 caractères pour démarrer',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(TherapeuticClass category) {
    switch (category) {
      case TherapeuticClass.ANTALGIQUE:
        return Colors.blue;
      case TherapeuticClass.ANTIBIOTIQUE:
        return Colors.orange;
      case TherapeuticClass.ANTIPALUDEEN:
        return Colors.red;
      case TherapeuticClass.ANTIHYPERTENSEUR:
        return Colors.purple;
      case TherapeuticClass.ANTIDIABETIQUE:
        return Colors.green;
      case TherapeuticClass.ANTIINFLAMMATOIRE:
        return Colors.cyan;
      case TherapeuticClass.ANTIHISTAMINIQUE:
        return Colors.pink;
      case TherapeuticClass.AUTRES:
        return Colors.grey;
    }
  }
}
