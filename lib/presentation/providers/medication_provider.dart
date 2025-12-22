import 'package:flutter/foundation.dart';
import 'package:easypharma_flutter/data/models/medication_model.dart';
import 'package:easypharma_flutter/data/repositories/medication_repository.dart';

class MedicationProvider extends ChangeNotifier {
  final MedicationRepository _repository;

  // État
  List<Medication> _searchResults = [];
  List<PharmacyMedication> _priceResults = [];
  List<Pharmacy> _nearbyPharmacies = [];

  bool _isLoading = false;
  String? _errorMessage;

  // Filtres
  String _searchQuery = '';
  TherapeuticClass? _selectedTherapeuticClass;
  String _sortBy = 'name'; // 'name', 'price'

  // Getters
  List<Medication> get searchResults => _searchResults;
  List<PharmacyMedication> get priceResults => _priceResults;
  List<Pharmacy> get nearbyPharmacies => _nearbyPharmacies;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;
  TherapeuticClass? get selectedTherapeuticClass => _selectedTherapeuticClass;
  String get sortBy => _sortBy;

  MedicationProvider(this._repository);

  /// Rechercher des médicaments par nom et catégorie
  Future<void> searchMedications(
    String query, {
    TherapeuticClass? therapeuticClass,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _searchQuery = query;
    _selectedTherapeuticClass = therapeuticClass;
    notifyListeners();

    try {
      final results = await _repository.searchMedications(
        name: query,
        therapeuticClass:
            therapeuticClass?.toString().split('.').last.toUpperCase(),
      );

      _searchResults = _sortMedications(results);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _searchResults = [];
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtenir les prix d'un médicament
  Future<void> getPricesForMedication(String medicationId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _repository.getPricesAcrossPharmacies(
        medicationId: medicationId,
      );
      _priceResults = _sortPrices(results);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _priceResults = [];
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtenir les pharmacies proches
  Future<void> getNearbyPharmacies({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _repository.getNearbyPharmacies(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
      _nearbyPharmacies = results;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _nearbyPharmacies = [];
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Définir le critère de tri
  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    // Trier les résultats actuels
    _searchResults = _sortMedications(_searchResults);
    _priceResults = _sortPrices(_priceResults);
    notifyListeners();
  }

  /// Filtrer les résultats actuels par catégorie
  void filterByTherapeuticClass(TherapeuticClass? therapeuticClass) {
    _selectedTherapeuticClass = therapeuticClass;
    if (therapeuticClass == null) {
      notifyListeners();
      return;
    }
    _searchResults =
        _searchResults
            .where((med) => med.therapeuticClass == therapeuticClass)
            .toList();
    notifyListeners();
  }

  /// Filtrer par plage de prix
  List<PharmacyMedication> filterByPriceRange(
    double minPrice,
    double maxPrice,
  ) {
    return _priceResults
        .where((pm) => pm.price >= minPrice && pm.price <= maxPrice)
        .toList();
  }

  /// Trier les médicaments
  List<Medication> _sortMedications(List<Medication> medications) {
    final sorted = List<Medication>.from(medications);
    switch (_sortBy) {
      case 'name':
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'price':
        // C'est pour les résultats de prix, pas applicable ici
        break;
    }
    return sorted;
  }

  /// Trier les prix
  List<PharmacyMedication> _sortPrices(List<PharmacyMedication> prices) {
    final sorted = List<PharmacyMedication>.from(prices);
    switch (_sortBy) {
      case 'price':
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'name':
        sorted.sort((a, b) => a.pharmacy.name.compareTo(b.pharmacy.name));
        break;
    }
    return sorted;
  }

  /// Réinitialiser les résultats
  void clearResults() {
    _searchResults = [];
    _priceResults = [];
    _searchQuery = '';
    _selectedTherapeuticClass = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Méthodes utilitaires pour les tests (permet d'injecter des données)
  @visibleForTesting
  void setSearchResultsForTest(List<Medication> results) {
    _searchResults = results;
    notifyListeners();
  }

  @visibleForTesting
  void setPriceResultsForTest(List<PharmacyMedication> results) {
    _priceResults = results;
    notifyListeners();
  }
}
