import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:easypharma_flutter/core/constants/api_constants.dart';
import 'package:easypharma_flutter/core/services/api_service.dart';
import 'package:easypharma_flutter/data/models/auth_response.dart';
import 'package:easypharma_flutter/data/models/user_model.dart';

class AuthRepository {
  final Dio _dio;
  final ApiService _apiService; // Champ pour ApiService

  AuthRepository(this._dio, this._apiService); // Constructeur modifié

  // === LOGIN ===
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final data = {'email': email, 'password': password};

      print('=== LOGIN REQUEST ===');
      print('Data: $data');

      final response = await _dio.post(ApiConstants.login, data: data);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['success'] == true) {
          return AuthResponse.fromJson(responseData['data']);
        } else {
          throw Exception(responseData['message'] ?? 'Échec de la connexion');
        }
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response!.data;
        throw Exception(errorData['message'] ?? 'Erreur lors de la connexion');
      } else {
        throw Exception('Erreur de connexion: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  // === REGISTER ===
  Future<AuthResponse> register({
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
    try {
      final data = {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'role': role.name,
        'address':
            (address == null || address.trim().isEmpty) ? null : address.trim(),
        'city': (city == null || city.trim().isEmpty) ? null : city.trim(),
        'pharmacyId': pharmacyId,
      };

      print('=== AUTH REPOSITORY REGISTER ===');
      print('Data: $data');

      final response = await _dio.post(ApiConstants.register, data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['success'] == true) {
          return AuthResponse.fromJson(responseData['data']);
        } else {
          throw Exception(responseData['message'] ?? 'Échec de l\'inscription');
        }
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('=== DIO ERROR ===');
      print('Error type: ${e.type}');
      print('Error message: ${e.message}');
      if (e.response != null) {
        print('Response status: ${e.response!.statusCode}');
        print('Response data: ${e.response!.data}');
      }

      if (e.response != null) {
        final errorData = e.response!.data;
        throw Exception(
          errorData['message'] ?? 'Erreur lors de l\'inscription',
        );
      } else {
        throw Exception('Erreur de connexion: ${e.message}');
      }
    } catch (e) {
      print('=== UNEXPECTED ERROR ===');
      print('Error: $e');
      throw Exception('Erreur inattendue: $e');
    }
  }

  // === GET PROFILE ===
  Future<User> getProfile(String accessToken) async {
    try {
      final response = await _dio.get(
        ApiConstants.getProfile,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['success'] == true) {
          return User.fromJson(responseData['data']);
        } else {
          throw Exception(
            responseData['message'] ?? 'Échec de la récupération du profil',
          );
        }
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response!.data;
        throw Exception(
          errorData['message'] ?? 'Erreur lors de la récupération du profil',
        );
      } else {
        throw Exception('Erreur de connexion: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  // === UPDATE PROFILE (NOUVELLE MÉTHODE) ===
  Future<User> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    String? address,
    String? city,
  }) async {
    try {
      // Préparer les données
      final Map<String, dynamic> updateData = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
      };

      if (address != null && address.trim().isNotEmpty) {
        updateData['address'] = address.trim();
      }

      if (city != null && city.trim().isNotEmpty) {
        updateData['city'] = city.trim();
      }

      print('=== UPDATE PROFILE REQUEST ===');
      print('Data to send: $updateData');
      print('Endpoint: ${ApiConstants.updateProfile}');
      print('Using ApiService.put()');

      // Utiliser ApiService qui gère automatiquement les tokens
      final response = await _apiService.put(
        ApiConstants.updateProfile,
        data: updateData,
        requiresAuth: true, // IMPORTANT: nécessite authentification
      );

      print('API Response status: ${response.statusCode}');
      print('API Response data: ${response.data}');

      if (response.statusCode == 200) {
        final dynamic responseData = response.data;

        if (responseData is Map) {
          final Map<String, dynamic> dataMap = Map<String, dynamic>.from(
            responseData,
          );

          if (dataMap['success'] == true && dataMap['data'] != null) {
            return User.fromJson(dataMap['data']);
          } else if (dataMap.containsKey('id')) {
            return User.fromJson(dataMap);
          } else {
            throw Exception(dataMap['message'] ?? 'Format de réponse invalide');
          }
        }
        throw Exception('Format de réponse invalide');
      } else {
        throw Exception(
          'Échec de la mise à jour du profil (${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      print('=== UPDATE PROFILE DIO ERROR ===');
      print('Error type: ${e.type}');
      print('Error message: ${e.message}');
      if (e.response != null) {
        print('Response status: ${e.response!.statusCode}');
        print('Response data: ${e.response!.data}');
      }
      rethrow;
    } catch (e) {
      print('=== UPDATE PROFILE UNEXPECTED ERROR ===');
      print('Error: $e');
      print('Stack trace: ${e.toString()}');
      rethrow;
    }
  }

  // === AUTRES MÉTHODES (optionnelles) ===

  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final data = {'refreshToken': refreshToken};

      final response = await _dio.post(ApiConstants.refreshToken, data: data);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['success'] == true) {
          return AuthResponse.fromJson(responseData['data']);
        } else {
          throw Exception(
            responseData['message'] ?? 'Échec du rafraîchissement du token',
          );
        }
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response!.data;
        throw Exception(
          errorData['message'] ?? 'Erreur lors du rafraîchissement du token',
        );
      } else {
        throw Exception('Erreur de connexion: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post(
        ApiConstants.logout,
        data: {'refreshToken': refreshToken},
      );
    } on DioException catch (e) {
      print('Erreur lors de la déconnexion: $e');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      print('=== FORGOT PASSWORD REQUEST ===');
      print('Email: $email');

      final response = await _dio.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );

      print('=== FORGOT PASSWORD RESPONSE ===');
      print('Status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = response.data;

        // Vérifier le format de la réponse
        if (responseData['success'] == true) {
          print('Email de réinitialisation envoyé avec succès!');
          return;
        } else {
          throw Exception(
            responseData['message'] ?? 'Erreur lors de l\'envoi de l\'email',
          );
        }
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('=== FORGOT PASSWORD DIO ERROR ===');
      print('Error type: ${e.type}');
      print('Error message: ${e.message}');
      if (e.response != null) {
        print('Status: ${e.response!.statusCode}');
        print('Response data: ${e.response!.data}');
        final errorData = e.response!.data;
        throw Exception(
          errorData['message'] ?? 'Erreur lors de l\'envoi de l\'email',
        );
      } else {
        throw Exception('Erreur de connexion: ${e.message}');
      }
    } catch (e) {
      print('=== FORGOT PASSWORD UNEXPECTED ERROR ===');
      print('Error: $e');
      throw Exception('Erreur inattendue: $e');
    }
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      print('=== RESET PASSWORD REQUEST ===');
      print('Token: ${token.substring(0, 20)}...');
      print('New password length: ${newPassword.length}');

      final response = await _dio.post(
        ApiConstants.resetPassword,
        data: {'token': token, 'newPassword': newPassword},
      );

      print('=== RESET PASSWORD RESPONSE ===');
      print('Status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = response.data;

        // Vérifier le format de la réponse
        if (responseData['success'] == true) {
          print('Password reset successful!');
          return;
        } else {
          throw Exception(
            responseData['message'] ??
                'Erreur lors de la réinitialisation du mot de passe',
          );
        }
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('=== RESET PASSWORD DIO ERROR ===');
      print('Error type: ${e.type}');
      print('Error message: ${e.message}');
      if (e.response != null) {
        print('Status: ${e.response!.statusCode}');
        print('Response data: ${e.response!.data}');
        final errorData = e.response!.data;
        throw Exception(
          errorData['message'] ?? 'Erreur lors de la réinitialisation',
        );
      } else {
        throw Exception('Erreur de connexion: ${e.message}');
      }
    } catch (e) {
      print('=== RESET PASSWORD UNEXPECTED ERROR ===');
      print('Error: $e');
      throw Exception('Erreur inattendue: $e');
    }
  }

  Future<void> deleteProfile() async {
    try {
      await _apiService.delete(ApiConstants.deleteProfile, requiresAuth: true);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _apiService.patch(
        ApiConstants.updatePassword,
        data: {'oldPassword': oldPassword, 'newPassword': newPassword},
        requiresAuth: true,
      );
    } catch (e) {
      rethrow;
    }
  }
}
