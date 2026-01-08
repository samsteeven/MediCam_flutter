import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easypharma_flutter/presentation/providers/medication_provider.dart';
import 'package:easypharma_flutter/data/models/medication_model.dart';
import 'package:easypharma_flutter/core/utils/notification_helper.dart';

/// Widget réutilisable pour la barre de recherche rapide de médicaments
class MedicationSearchBar extends StatefulWidget {
  final Function(String)? onSearch;
  final bool showButton;
  final double? userLat;
  final double? userLon;
  final bool readOnly;
  final VoidCallback? onTap;

  const MedicationSearchBar({
    super.key,
    this.onSearch,
    this.showButton = true,
    this.userLat,
    this.userLon,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<MedicationSearchBar> createState() => _MedicationSearchBarState();
}

class _MedicationSearchBarState extends State<MedicationSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              readOnly: widget.readOnly,
              onTap: widget.onTap,
              decoration: InputDecoration(
                hintText: 'Rechercher un médicament',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _controller.text.isNotEmpty && !widget.readOnly
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                            setState(() {});
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {});
                widget.onSearch?.call(value);
              },
              onSubmitted: (value) {
                if (!widget.readOnly && value.length >= 3) {
                  context.read<MedicationProvider>().searchMedications(
                    value,
                    userLat: widget.userLat,
                    userLon: widget.userLon,
                  );
                }
              },
            ),
          ),
          if (widget.showButton && !widget.readOnly) ...[
            IconButton(
              icon: const Icon(Icons.tune),
              onPressed: () => _showFilterSheet(context),
              tooltip: 'Filtres',
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: FloatingActionButton.small(
                elevation: 0,
                backgroundColor: Colors.blue.shade700,
                onPressed: () {
                  if (_controller.text.length >= 3) {
                    context.read<MedicationProvider>().searchMedications(
                      _controller.text,
                      userLat: widget.userLat,
                      userLon: widget.userLon,
                    );
                  } else {
                    NotificationHelper.showError(
                      context,
                      'Entrez au moins 3 caractères',
                    );
                  }
                },
                child: const Icon(Icons.search, color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final medicationProvider = context.read<MedicationProvider>();

    // States locaux pour le bottom sheet
    String localSortBy = medicationProvider.sortBy;
    TherapeuticClass? localTherapeuticClass =
        medicationProvider.selectedTherapeuticClass;
    bool? localRequiresPrescription = medicationProvider.requiresPrescription;
    String? localAvailability = medicationProvider.availability;
    double? localMinPrice = medicationProvider.minPrice;
    double? localMaxPrice = medicationProvider.maxPrice;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filtres avancés',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              localSortBy = 'NEAREST';
                              localTherapeuticClass = null;
                              localRequiresPrescription = null;
                              localAvailability = null;
                              localMinPrice = null;
                              localMaxPrice = null;
                            });
                          },
                          child: const Text('Réinitialiser'),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 10),

                    // --- TRI ---
                    const Text(
                      'Trier par',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildFilterChip(
                          label: 'À proximité',
                          selected: localSortBy == 'NEAREST',
                          onSelected:
                              (s) =>
                                  setModalState(() => localSortBy = 'NEAREST'),
                        ),
                        _buildFilterChip(
                          label: 'Nom',
                          selected: localSortBy == 'NAME',
                          onSelected:
                              (s) => setModalState(() => localSortBy = 'NAME'),
                        ),
                        _buildFilterChip(
                          label: 'Prix',
                          selected: localSortBy == 'PRICE',
                          onSelected:
                              (s) => setModalState(() => localSortBy = 'PRICE'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- CLASSE THÉRAPEUTIQUE ---
                    const Text(
                      'Classe thérapeutique',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children:
                          TherapeuticClass.values.map((tc) {
                            return _buildFilterChip(
                              label: tc.displayName,
                              selected: localTherapeuticClass == tc,
                              onSelected: (selected) {
                                setModalState(() {
                                  localTherapeuticClass = selected ? tc : null;
                                });
                              },
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // --- ORDONNANCE ---
                    const Text(
                      'Ordonnance requise',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildFilterChip(
                          label: 'Peu importe',
                          selected: localRequiresPrescription == null,
                          onSelected:
                              (s) => setModalState(
                                () => localRequiresPrescription = null,
                              ),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Oui',
                          selected: localRequiresPrescription == true,
                          onSelected:
                              (s) => setModalState(
                                () => localRequiresPrescription = true,
                              ),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Non',
                          selected: localRequiresPrescription == false,
                          onSelected:
                              (s) => setModalState(
                                () => localRequiresPrescription = false,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- DISPONIBILITÉ ---
                    const Text(
                      'Disponibilité',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildFilterChip(
                          label: 'Toutes',
                          selected: localAvailability == null,
                          onSelected:
                              (s) =>
                                  setModalState(() => localAvailability = null),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'En stock',
                          selected: localAvailability == 'IN_STOCK',
                          onSelected:
                              (s) => setModalState(
                                () => localAvailability = 'IN_STOCK',
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- PRIX ---
                    const Text(
                      'Plage de prix (CFA)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Min',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged:
                                (v) => localMinPrice = double.tryParse(v),
                            controller: TextEditingController(
                              text: localMinPrice?.toString() ?? '',
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('-'),
                        ),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Max',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged:
                                (v) => localMaxPrice = double.tryParse(v),
                            controller: TextEditingController(
                              text: localMaxPrice?.toString() ?? '',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // --- BOUTON APPLIQUER ---
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          medicationProvider.searchMedications(
                            _controller.text,
                            userLat: widget.userLat,
                            userLon: widget.userLon,
                            sortBy: localSortBy,
                            therapeuticClass: localTherapeuticClass,
                            requiresPrescription: localRequiresPrescription,
                            availability: localAvailability,
                            minPrice: localMinPrice,
                            maxPrice: localMaxPrice,
                          );
                        },
                        child: const Text(
                          'Appliquer les filtres',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: Colors.blue.shade700,
      backgroundColor: Colors.grey.shade100,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black87,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
    );
  }
}
