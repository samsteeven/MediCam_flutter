import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:easypharma_flutter/core/constants/api_constants.dart';
import 'package:easypharma_flutter/core/constants/app_constants.dart';

class ApiService {
  late Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _isRefreshing = false; // Add this flag to prevent multiple refresh calls

  Dio get dio => _dio;
  ApiService() {
    _initDio();
  }

  Future<void> _initDio() async {
    final String url = await ApiConstants.baseUrl;
    _dio = Dio(
      BaseOptions(
        baseUrl: url,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (log) => print('DIO: $log'),
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final token = await _secureStorage.read(
            key: AppConstants.accessTokenKey,
          );
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          print(' Request: ${options.method} ${options.path}');
          if (options.data != null) {
            print(' Request Data: ${options.data}');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            ' Response: ${response.statusCode} ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          print(' Error: ${error.type} - ${error.message}');
          if (error.response != null) {
            print(' Status: ${error.response!.statusCode}');
            print(' Response Data: ${error.response!.data}');
          }

          // Handle 401 Unauthorized
          if (error.response?.statusCode == 401) {
            // Check if we're already refreshing
            if (_isRefreshing) {
              // If already refreshing, wait and retry
              await Future.delayed(const Duration(milliseconds: 100));
              final token = await _secureStorage.read(key: 'access_token');
              if (token != null) {
                error.requestOptions.headers['Authorization'] = 'Bearer $token';
                final retryResponse = await _dio.fetch<dynamic>(
                  error.requestOptions,
                );
                return handler.resolve(retryResponse);
              }
            } else {
              // Token expired, try to refresh
              try {
                _isRefreshing = true;
                final newToken = await _handleTokenExpired();
                if (newToken != null) {
                  // Update the failed request with new token
                  error.requestOptions.headers['Authorization'] =
                      'Bearer $newToken';

                  // Create a new Dio instance for retry to avoid interceptor loop
                  final retryDio = Dio(_dio.options);
                  final retryResponse = await retryDio.fetch<dynamic>(
                    error.requestOptions,
                  );
                  _isRefreshing = false;
                  return handler.resolve(retryResponse);
                }
              } catch (refreshError) {
                _isRefreshing = false;
                print(' Token refresh failed: $refreshError');
                await _secureStorage.deleteAll();
                // Pass the original error
                return handler.next(error);
              }
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  // Aide à attendre que Dio soit prêt
  Future<void> ensureDioReady() async {
    // Si _dio n'est pas encore initialisé, on attend un peu
    // ou on rappelle l'init si nécessaire.
    int retry = 0;
    while (retry < 10) {
      try {
        if (_dio != null) return;
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 100));
      retry++;
    }
  }

  // GET request
  Future<String?> _handleTokenExpired() async {
    try {
      final refreshToken = await _secureStorage.read(
        key: AppConstants.refreshTokenKey,
      );
      if (refreshToken == null) {
        // No refresh token, clear storage
        await _secureStorage.deleteAll();
        return null;
      }
      final String currentBaseUrl = await ApiConstants.baseUrl;
      // Create a new Dio instance without interceptor to avoid loop
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: currentBaseUrl,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      // Try to refresh token
      final response = await refreshDio.post(
        ApiConstants.refreshToken,
        data: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          final newAccessToken = responseData['data']['access_token'];
          final newRefreshToken = responseData['data']['refresh_token'];

          // Save new tokens
          await _secureStorage.write(
            key: AppConstants.accessTokenKey,
            value: newAccessToken,
          );
          await _secureStorage.write(
            key: AppConstants.refreshTokenKey,
            value: newRefreshToken,
          );

          return newAccessToken;
        }
      }
      return null;
    } catch (e) {
      print(' Token refresh failed: $e');
      await _secureStorage.deleteAll();
      return null;
    }
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParams,
    bool requiresAuth = true,
  }) async {
    await ensureDioReady();

    try {
      // 2. On prépare les headers
      final options = Options(headers: await _getHeaders(requiresAuth));

      // 3. On lance la requête avec une syntaxe scannable
      return await _dio.get(
        path,
        queryParameters: queryParams,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    bool requiresAuth = true,
  }) async {
    await ensureDioReady();
    try {
      final options = Options(headers: await _getHeaders(requiresAuth));

      // DEBUG
      print('=== API SERVICE POST ===');
      print('Path: $path');
      print('Data type: ${data.runtimeType}');
      print('Data content: $data');

      return await _dio.post(
        path,
        data: data, // Dio encode automatiquement pour nous
        queryParameters: queryParams,
        options: options,
      );
    } on DioException catch (e) {
      print('=== API SERVICE POST ERROR ===');
      print('Error: ${e.message}');
      throw _handleError(e);
    }
  } // PUT request

  // CORRECTION dans api_service.dart - ligne 145
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    bool requiresAuth = true,
  }) async {
    await ensureDioReady();
    try {
      final options = Options(headers: await _getHeaders(requiresAuth));

      // DEBUG
      print('=== API SERVICE PUT ===');
      print('Path: $path');
      print('Data: $data');
      print('Requires auth: $requiresAuth');

      // CORRECTION: Ne pas utiliser jsonEncode si data est déjà un Map
      return await _dio.put(
        path,
        data: data, // Dio va convertir en JSON automatiquement
        queryParameters: queryParams,
        options: options,
      );
    } on DioException catch (e) {
      print('=== API SERVICE PUT ERROR ===');
      print('Error type: ${e.type}');
      print('Error message: ${e.message}');
      if (e.response != null) {
        print('Response status: ${e.response!.statusCode}');
        print('Response data: ${e.response!.data}');
      }
      throw _handleError(e);
    }
  }

  // PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    bool requiresAuth = true,
  }) async {
    await ensureDioReady();
    try {
      final options = Options(headers: await _getHeaders(requiresAuth));

      return await _dio.patch(
        path,
        data: data is String ? data : jsonEncode(data),
        queryParameters: queryParams,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    bool requiresAuth = true,
  }) async {
    await ensureDioReady();
    try {
      final options = Options(headers: await _getHeaders(requiresAuth));

      return await _dio.delete(
        path,
        data: data is String ? data : jsonEncode(data),
        queryParameters: queryParams,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get headers with authentication
  Future<Map<String, String>> _getHeaders(bool requiresAuth) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await _secureStorage.read(
        key: AppConstants.accessTokenKey,
      ); // BONNE CLÉ
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  } // Error handler

  Exception _handleError(DioException error) {
    if (error.response != null) {
      final responseData = error.response!.data;
      if (responseData is Map) {
        return Exception(responseData['message'] ?? 'Une erreur est survenue');
      } else if (responseData is String) {
        return Exception(responseData);
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('La requête a expiré. Veuillez réessayer.');
      case DioExceptionType.badResponse:
        return Exception('Erreur serveur (${error.response?.statusCode})');
      case DioExceptionType.cancel:
        return Exception('Requête annulée');
      case DioExceptionType.unknown:
        return Exception('Erreur de connexion. Vérifiez votre internet.');
      default:
        return Exception('Une erreur inattendue est survenue');
    }
  }

  // Clear all tokens
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: AppConstants.accessTokenKey);
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
    await _secureStorage.delete(key: 'user_role');
    await _secureStorage.delete(key: AppConstants.userDataKey);
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    // MODIFIEZ cette ligne :
    final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  // Get current token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConstants.accessTokenKey);
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConstants.refreshTokenKey);
  }

  // Save login data
  Future<void> saveLoginData({
    required String accessToken,
    required String refreshToken,
    required Map<String, dynamic> userData,
  }) async {
    // MODIFIEZ toutes ces lignes :
    await _secureStorage.write(
      key: AppConstants.accessTokenKey,
      value: accessToken,
    );
    await _secureStorage.write(
      key: AppConstants.refreshTokenKey,
      value: refreshToken,
    );
    await _secureStorage.write(
      key: 'user_role',
      value: userData['role']?.toString() ?? '',
    );
    await _secureStorage.write(
      key: AppConstants.userDataKey,
      value: jsonEncode(userData),
    );
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    // MODIFIEZ cette ligne :
    final userDataString = await _secureStorage.read(
      key: AppConstants.userDataKey,
    );
    if (userDataString != null) {
      return jsonDecode(userDataString);
    }
    return null;
  }

  Future<void> debugStorage() async {
    final accessToken = await _secureStorage.read(
      key: AppConstants.accessTokenKey,
    );
    final refreshToken = await _secureStorage.read(
      key: AppConstants.refreshTokenKey,
    );
    final userData = await _secureStorage.read(key: AppConstants.userDataKey);

    print('=== DEBUG STORAGE ===');
    print('Access Token existe: ${accessToken != null}');
    print('Refresh Token existe: ${refreshToken != null}');
    print('User Data: $userData');
  }
}
