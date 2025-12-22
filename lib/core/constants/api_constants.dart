import 'dart:io';

class ApiConstants {
  static String get baseUrl {
    // Si on tourne sur un émulateur Android
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api/v1';
    }
    // Pour iOS (simulateur ou physique) et Android physique
    return 'http://192.168.1.179:8080/api/v1';
  }

  // Endpoints d'authentification
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String getProfile = '/auth/me';

  // Endpoints de profil
  static const String updateProfile = '/users/me';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Endpoints de session
  static const String refreshToken = '/auth/refresh-token';

  // Endpoints futurs
  static const String searchMedications = '/medications/search';
  static const String myOrders = '/orders/my-orders';
}

class ApiHeaders {
  static const Map<String, String> basicHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) {
    return {...basicHeaders, 'Authorization': 'Bearer $token'};
  }
}
