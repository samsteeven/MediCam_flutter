import 'package:flutter/foundation.dart';
import 'package:easypharma_flutter/data/models/pharmacy_model.dart';
import 'package:easypharma_flutter/data/repositories/pharmacies_repository.dart';

class PharmaciesProvider extends ChangeNotifier {
  final PharmaciesRepository _repository;

  // État
  List<Pharmacy> _allPharmacies = [];
  List<Pharmacy> _nearbyPharmacies = [];
  List<Pharmacy> _searchResults = [];
  Pharmacy? _selectedPharmacy;

  bool _isLoading = false;
  String? _errorMessage;

  // Filtres
  String _searchQuery = '';
  String? _selectedCity;

  // Getters
  List<Pharmacy> get allPharmacies => _allPharmacies;
  List<Pharmacy> get nearbyPharmacies => _nearbyPharmacies;
  List<Pharmacy> get searchResults => _searchResults;
  Pharmacy? get selectedPharmacy => _selectedPharmacy;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;
  String? get selectedCity => _selectedCity;

  PharmaciesProvider(this._repository);

  /// Récupérer toutes les pharmacies
  Future<void> fetchAllPharmacies() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allPharmacies = await _repository.getAllPharmacies();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _allPharmacies = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Récupérer une pharmacie par ID
  Future<void> selectPharmacyById(String pharmacyId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedPharmacy = await _repository.getPharmacyById(pharmacyId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _selectedPharmacy = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Récupérer les pharmacies à proximité
  Future<void> fetchNearbyPharmacies({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _nearbyPharmacies = await _repository.getNearbyPharmacies(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _nearbyPharmacies = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Rechercher les pharmacies par nom
  Future<void> searchPharmaciesByName(String name) async {
    _isLoading = true;
    _errorMessage = null;
    _searchQuery = name;
    notifyListeners();

    try {
      _searchResults = await _repository.searchByName(name);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Rechercher les pharmacies par ville
  Future<void> searchPharmaciesByCity(String city) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedCity = city;
    notifyListeners();

    try {
      _searchResults = await _repository.searchByCity(city);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Récupérer les pharmacies approuvées par ville
  Future<void> fetchApprovedPharmaciesByCity(String city) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedCity = city;
    notifyListeners();

    try {
      _searchResults = await _repository.getApprovedByCity(city);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Rechercher les pharmacies par statut
  Future<void> searchPharmaciesByStatus(String status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _searchResults = await _repository.searchByStatus(status);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Réinitialiser les résultats de recherche
  void clearSearch() {
    _searchResults = [];
    _searchQuery = '';
    _selectedCity = null;
    notifyListeners();
  }
}
