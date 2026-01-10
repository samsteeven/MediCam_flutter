import 'package:flutter/foundation.dart';
import 'package:easypharma_flutter/data/models/medication_model.dart';
import 'package:easypharma_flutter/data/repositories/medication_repository.dart';

class MedicationProvider extends ChangeNotifier {
  final MedicationRepository _repository;

  // État
  List<PharmacyMedication> _searchResults = [];
  List<Medication> _catalogResults = [];
  List<PharmacyMedication> _priceResults = [];
  List<Pharmacy> _nearbyPharmacies = [];

  bool _isLoading = false;
  String? _errorMessage;

  // Filtres
  String _searchQuery = '';
  TherapeuticClass? _selectedTherapeuticClass;
  String _sortBy = 'NEAREST'; // 'NAME', 'PRICE', 'NEAREST'
  bool? _requiresPrescription;
  double? _minPrice;
  double? _maxPrice;
  String? _availability; // 'IN_STOCK', 'OUT_OF_STOCK'

  // Getters
  List<PharmacyMedication> get searchResults => _searchResults;
  List<Medication> get catalogResults => _catalogResults;
  List<PharmacyMedication> get priceResults => _priceResults;
  List<Pharmacy> get nearbyPharmacies => _nearbyPharmacies;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;
  TherapeuticClass? get selectedTherapeuticClass => _selectedTherapeuticClass;
  String get sortBy => _sortBy;
  bool? get requiresPrescription => _requiresPrescription;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  String? get availability => _availability;

  MedicationProvider(this._repository);

  /// Rechercher des médicaments avec filtres avancés
  Future<void> searchMedications(
    String query, {
    TherapeuticClass? therapeuticClass,
    double? userLat,
    double? userLon,
    String? sortBy,
    bool? requiresPrescription,
    double? minPrice,
    double? maxPrice,
    String? availability,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _searchQuery = query;
    _selectedTherapeuticClass = therapeuticClass ?? _selectedTherapeuticClass;
    _sortBy = sortBy ?? _sortBy;
    _requiresPrescription = requiresPrescription ?? _requiresPrescription;
    _minPrice = minPrice ?? _minPrice;
    _maxPrice = maxPrice ?? _maxPrice;
    _availability = availability ?? _availability;
    notifyListeners();

    try {
      final results = await _repository.searchMedications(
        name: query,
        therapeuticClass:
            _selectedTherapeuticClass?.toString().split('.').last.toUpperCase(),
        userLat: userLat,
        userLon: userLon,
        sortBy: _sortBy,
        requiresPrescription: _requiresPrescription,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        availability: _availability,
      );

      _searchResults =
          results; // Le tri est fait côté serveur ou par _sortPharmacyMedications si besoin localement
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
    double radiusKm = 5.0,
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

  /// Filtrer les médicaments (Catalogue Global)
  Future<void> fetchFilteredMedications(Map<String, dynamic> filters) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _repository.filterMedications(filters);
      _catalogResults = results;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _catalogResults = [];
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Récupérer par classe thérapeutique (Catalogue Global)
  Future<void> fetchMedicationsByClass(String therapeuticClass) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _repository.getMedicationsByClass(therapeuticClass);
      _catalogResults = results;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _catalogResults = [];
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Récupérer les médicaments sur ordonnance (Catalogue Global)
  Future<void> fetchPrescriptionRequiredMedications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _repository.getPrescriptionRequiredMedications();
      _catalogResults = results;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _catalogResults = [];
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Récupérer les top médicaments (Admin Stats / Dashboard)
  Future<void> fetchTopSoldMedications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _repository.getTopSoldMedications();
      _catalogResults = results;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _catalogResults = [];
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
    _searchResults = _sortPharmacyMedications(_searchResults);
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
            .where((pm) => pm.medication.therapeuticClass == therapeuticClass)
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

  /// Trier les médicaments (PharmacyMedication)
  List<PharmacyMedication> _sortPharmacyMedications(
    List<PharmacyMedication> medications,
  ) {
    final sorted = List<PharmacyMedication>.from(medications);
    switch (_sortBy) {
      case 'name':
        sorted.sort((a, b) => a.medication.name.compareTo(b.medication.name));
        break;
      case 'price':
        sorted.sort((a, b) => a.price.compareTo(b.price));
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

  /// Réinitialiser les résultats et les filtres
  void clearResults() {
    _searchResults = [];
    _priceResults = [];
    _searchQuery = '';
    _selectedTherapeuticClass = null;
    _sortBy = 'NEAREST';
    _requiresPrescription = null;
    _minPrice = null;
    _maxPrice = null;
    _availability = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Méthodes utilitaires pour les tests (permet d'injecter des données)
  @visibleForTesting
  void setSearchResultsForTest(List<PharmacyMedication> results) {
    _searchResults = results;
    notifyListeners();
  }

  @visibleForTesting
  void setPriceResultsForTest(List<PharmacyMedication> results) {
    _priceResults = results;
    notifyListeners();
  }
}
