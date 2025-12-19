import 'package:flutter/material.dart';

/// Provider pour gérer l'état de navigation des écrans d'accueil
/// Persiste l'index de navigation et synchronise avec l'état global
class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void reset() {
    _currentIndex = 0;
    notifyListeners();
  }
}
