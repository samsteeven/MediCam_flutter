import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl {
    // Si on tourne sur un émulateur Android
    if (kIsWeb) {
      // Pour le web, on utilise l'URL publique
      return "http://localhost:8080/api/v1";
    }
    // Pour iOS (simulateur ou physique) et Android physique
    return "https://unconvoluted-prepreference-jeraldine.ngrok-free.dev/api/v1";
  }

  // === AUTHENTIFICATION ===
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String getProfile = '/auth/me';

  // === USERS ===
  static const String users = '/users';
  static const String updateProfile = '/users/me';
  static const String updatePassword = '/users/me/password';
  static const String myPharmacyUsers = '/users/my-pharmacy';

  // === PHARMACIES ===
  static const String pharmacies = '/pharmacies';
  static const String nearbyPharmacies = '/pharmacies/nearby';
  static const String searchPharmaciesByName = '/pharmacies/search/by-name';
  static const String searchPharmaciesByCity = '/pharmacies/search/by-city';
  static const String searchPharmaciesByStatus = '/pharmacies/search/by-status';
  static const String approvedPharmaciesByCity = '/pharmacies/approved/by-city';
  static const String pharmaciesByLicense = '/pharmacies/by-license';

  // === EMPLOYEES ===
  static String pharmacyEmployees(String pharmacyId) =>
      '/pharmacies/$pharmacyId/employees';

  // === INVENTORY ===
  static String pharmacyMedications(String pharmacyId) =>
      '/pharmacies/$pharmacyId/medications';

  // === MEDICATIONS ===
  static const String medications = '/medications';
  static const String searchMedications = '/medications/search';
  static const String filterMedications = '/medications/filter';
  static const String medicationsByClass = '/medications/by-class';
  static const String prescriptionRequired =
      '/medications/prescription-required';

  // === PATIENT SEARCH ===
  static const String patientSearch = '/patient/search';

  // === ORDERS ===
  static const String orders = '/orders';
  static const String myOrders = '/orders/my-orders';
  static String pharmacyOrders(String pharmacyId) =>
      '/orders/pharmacy-orders/$pharmacyId';

  // === DELIVERIES ===
  static const String myDeliveryStats = '/deliveries/my-stats';
  static const String myDeliveries = '/deliveries/my-deliveries';
  static const String ongoingDeliveries = '/deliveries/my-deliveries/ongoing';
  static String deliveryStatus(String deliveryId) =>
      '/deliveries/$deliveryId/status';
  static String deliveryProof(String deliveryId) =>
      '/deliveries/$deliveryId/proof';
  static String deliveryLocation(String deliveryId) =>
      '/deliveries/$deliveryId/location';

  // === PAYMENTS ===
  static const String processPayment = '/payments/process';
  static String paymentReceipt(String paymentId) =>
      '/payments/$paymentId/receipt';
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
