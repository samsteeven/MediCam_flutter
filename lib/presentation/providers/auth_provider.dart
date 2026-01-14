import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easypharma_flutter/core/services/api_service.dart';
import 'package:easypharma_flutter/data/models/user_model.dart';
import 'package:easypharma_flutter/data/models/auth_response.dart';
import 'package:easypharma_flutter/data/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  final AuthRepository _authRepository;
  final SharedPreferences _prefs;

  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  AuthProvider({
    required ApiService apiService,
    required AuthRepository authRepository,
    required SharedPreferences prefs,
  }) : _apiService = apiService,
       _authRepository = authRepository,
       _prefs = prefs;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated {
    return _user != null;
  }

  bool get isInitialized => _isInitialized;

  // Initialize auth provider (check if user is logged in)
  // Initialize auth provider (check if user is logged in)
  // Initialize auth provider (check if user is logged in)
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Check if user is authenticated via tokens
      final isAuthenticated = await _apiService.isAuthenticated();

      if (isAuthenticated) {
        // Get token
        final token = await _apiService.getToken();
        if (token != null) {
          try {
            // Try to fetch fresh user profile from API
            final userProfile = await _authRepository.getProfile(token);
            _user = userProfile;

            // Save updated user data locally
            await _apiService.saveLoginData(
              accessToken: token,
              refreshToken: await _apiService.getRefreshToken() ?? '',
              userData: userProfile.toJson(),
            );
          } catch (e) {
            print('Failed to fetch profile from API: $e');
            // If API fails (e.g. offline), try to load from local storage
            final localData = await _apiService.getUserData();
            if (localData != null) {
              _user = User.fromJson(localData);
              print('Loaded user from local storage');
            } else {
              // If no local data, then we must clear everything
              await _apiService.clearTokens();
              _user = null;
            }
          }
        }
      } else {
        // SI NON AUTHENTIFIÉ, NE PAS CHARGER L'UTILISATEUR !
        _user = null;
        await _apiService.clearTokens();
      }
    } catch (e) {
      _error = e.toString();
      print('Error initializing auth: $e');

      // Try fallback to local data even if general error
      final localData = await _apiService.getUserData();
      if (localData != null) {
        _user = User.fromJson(localData);
      } else {
        _user = null;
        await _apiService.clearTokens();
      }
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Login user
  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authResponse = await _authRepository.login(
        email: email,
        password: password,
      );

      // DEBUG: Vérifiez le nouveau token
      print('=== LOGIN SUCCESS - NEW TOKEN ===');
      print(
        'New access token: ${authResponse.accessToken.substring(0, 30)}...',
      );
      print('New refresh token: ${authResponse.refreshToken}');

      // Sauvegardez les tokens
      await _apiService.saveLoginData(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        userData: authResponse.user.toJson(),
      );

      // DEBUG: Vérifiez que c'est bien sauvegardé
      await _apiService.debugStorage();

      _user = authResponse.user;
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register new user
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required UserRole role,
    String? address,
    String? city,
    String? pharmacyId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authResponse = await _authRepository.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        role: role,
        address: address,
        city: city,
        pharmacyId: pharmacyId,
      );

      // Save tokens and user data
      await _apiService.saveLoginData(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        userData: authResponse.user.toJson(),
      );

      _user = authResponse.user;
      _error = null;

      // DEBUG: Vérifier que l'utilisateur a des valeurs non null
      print('=== REGISTER SUCCESS ===');
      print(
        'User address: ${_user!.address} (type: ${_user!.address.runtimeType})',
      );
      print('User city: ${_user!.city} (type: ${_user!.city.runtimeType})');
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get refresh token for server logout
      final refreshToken = await _apiService.getToken();

      if (refreshToken != null) {
        try {
          await _authRepository.logout(refreshToken);
        } catch (e) {
          // Even if server logout fails, clear local tokens
          print('Server logout failed: $e');
        }
      }

      // Clear local storage
      await _apiService.clearTokens();
      await _prefs.clear();

      _user = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
      // Still clear local data even on error
      await _apiService.clearTokens();
      await _prefs.clear();
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Forgot password
  Future<void> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authRepository.forgotPassword(email);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset password
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authRepository.resetPassword(
        token: token,
        newPassword: newPassword,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get current user profile (refresh from API)
  Future<User?> getCurrentUser() async {
    try {
      final token = await _apiService.getToken();
      if (token == null) {
        _user = null;
        notifyListeners();
        return null;
      }

      final user = await _authRepository.getProfile(token);
      _user = user;

      // Get refresh token
      final refreshToken = await _apiService.getToken();

      // Update stored user data
      await _apiService.saveLoginData(
        accessToken: token,
        refreshToken: refreshToken ?? '', // Fournir une chaîne vide si null
        userData: user.toJson(),
      );

      notifyListeners();
      return user;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Refresh token
  Future<void> refreshToken() async {
    try {
      final token = await _apiService.getToken();
      if (token == null) {
        await logout();
        return;
      }

      final authResponse = await _authRepository.refreshToken(token);

      await _apiService.saveLoginData(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        userData: _user?.toJson() ?? {},
      );
    } catch (e) {
      // If refresh fails, logout user
      await logout();
      rethrow;
    }
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    String? address,
    String? city,
  }) async {
    if (_user == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      print('=== AUTH PROVIDER UPDATE PROFILE START ===');
      print('User email: ${_user!.email}');
      print('User token exists: ${await _apiService.getToken() != null}');
      // IMPORTANT: Récupérer l'email de l'utilisateur actuel
      final currentEmail = _user!.email;

      if (currentEmail.isEmpty) {
        throw Exception('Email utilisateur non disponible');
      }
      // Appeler le repository
      final updatedUser = await _authRepository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: currentEmail, // Utiliser l'email actuel
        phone: phone,
        address: address,
        city: city,
      );

      print('=== UPDATE PROFILE SUCCESS ===');
      print('Updated user: ${updatedUser.toJson()}');

      // Mettre à jour l'utilisateur local
      _user = updatedUser;

      // Sauvegarder si nécessaire
      final token = await _apiService.getToken();
      if (token != null) {
        await _apiService.saveLoginData(
          accessToken: token,
          refreshToken: await _apiService.getRefreshToken() ?? '',
          userData: _user!.toJson(),
        );
      }

      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print('=== UPDATE PROFILE ERROR ===');
      print('Error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete user account
  Future<void> deleteProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.deleteProfile();

      // Clear local storage after successful deletion
      await _apiService.clearTokens();
      await _prefs.clear();

      _user = null;
      _error = null;
    } catch (e) {
      String errorMessage = e.toString();
      // Check for backend data integrity violation (Foreign Key Constraint)
      if (errorMessage.contains('DataIntegrityViolationException') ||
          errorMessage.contains('constraint')) {
        const friendlyMessage =
            "Impossible de supprimer le compte car des données (historique, commandes) y sont liées. Veuillez contacter le support.";
        _error = friendlyMessage;
        throw Exception(friendlyMessage);
      } else {
        _error = errorMessage;
        rethrow;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get user role for navigation
  String? get userRole => _user?.role.name;

  // Check if user has specific role
  bool hasRole(UserRole role) => _user?.role == role;

  // Get home route based on user role
  String? get homeRoute {
    if (_user == null) return '/login';

    switch (_user!.role) {
      case UserRole.PATIENT:
        return '/patient-home';
      case UserRole.DELIVERY:
        return '/delivery-home';
      default:
        return '/profile';
    }
  }
}
