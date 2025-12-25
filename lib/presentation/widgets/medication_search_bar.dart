import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easypharma_flutter/presentation/providers/medication_provider.dart';

/// Widget réutilisable pour la barre de recherche rapide de médicaments
class MedicationSearchBar extends StatefulWidget {
  final Function(String)? onSearch;
  final bool showButton;

  const MedicationSearchBar({super.key, this.onSearch, this.showButton = true});

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
              decoration: InputDecoration(
                hintText: 'Rechercher un médicament',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _controller.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                            setState(() {});
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              onChanged: (value) {
                setState(() {});
                widget.onSearch?.call(value);
              },
              onSubmitted: (value) {
                if (value.length >= 3) {
                  context.read<MedicationProvider>().searchMedications(value);
                  Navigator.pushNamed(context, '/medication-search');
                }
              },
            ),
          ),
          if (widget.showButton)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: FloatingActionButton.small(
                onPressed: () {
                  if (_controller.text.length >= 3) {
                    context.read<MedicationProvider>().searchMedications(
                      _controller.text,
                    );
                    Navigator.pushNamed(context, '/medication-search');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Entrez au moins 3 caractères'),
                      ),
                    );
                  }
                },
                child: const Icon(Icons.search),
              ),
            ),
        ],
      ),
    );
  }
}
