class ApiConstants {
  static String get baseUrl {
    return "https://unconvoluted-prepreference-jeraldine.ngrok-free.dev/api/v1";
  }

  // === ADMIN DASHBOARD ===
  static const String adminTopSold = '/admin/dashboard/top-medications/sold';
  static const String adminTopSearched =
      '/admin/dashboard/top-medications/searched';
  static const String adminStats = '/admin/dashboard/stats';

  // === AUTHENTICATION ===
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
  static const String deleteProfile = '/users/me';
  static const String updatePassword = '/users/me/password';
  static const String myPharmacyUsers = '/users/my-pharmacy';
  static String userById(String id) => '/users/$id';
  static String userRole(String id) => '/users/$id/role';

  // === PHARMACIES ===
  static const String pharmacies = '/pharmacies';
  static const String nearbyPharmacies = '/pharmacies/nearby';
  static const String searchPharmaciesByName = '/pharmacies/search/by-name';
  static const String searchPharmaciesByCity = '/pharmacies/search/by-city';
  static const String searchPharmaciesByStatus = '/pharmacies/search/by-status';
  static const String approvedPharmaciesByCity = '/pharmacies/approved/by-city';
  static const String pharmaciesByLicense = '/pharmacies/by-license';
  static String pharmacyByLicense(String license) =>
      '$pharmaciesByLicense/$license';
  static String pharmacyById(String id) => '/pharmacies/$id';
  static String pharmacyStatus(String id) => '/pharmacies/$id/status';

  // === EMPLOYEES ===
  static String pharmacyEmployees(String pharmacyId) =>
      '/pharmacies/$pharmacyId/employees';
  static String pharmacyEmployeesByRole(String pharmacyId, String role) =>
      '/pharmacies/$pharmacyId/employees/role/$role';
  static String removePharmacyEmployee(String phId, String empId) =>
      '/pharmacies/$phId/employees/$empId';

  // === INVENTORY ===
  static String pharmacyMedications(String pharmacyId) =>
      '/pharmacies/$pharmacyId/medications';
  static String updateStock(String pharmacyId, String medicationId) =>
      '/pharmacies/$pharmacyId/medications/$medicationId/stock';
  static String updatePrice(String pharmacyId, String medicationId) =>
      '/pharmacies/$pharmacyId/medications/$medicationId/price';
  static String removePharmacyMedication(
    String pharmacyId,
    String medicationId,
  ) => '/pharmacies/$pharmacyId/medications/$medicationId';

  // === MEDICATIONS ===
  static const String medications = '/medications';
  static const String searchMedications = '/medications/search';
  static const String filterMedications = '/medications/filter';
  static String medicationById(String id) => '/medications/$id';
  static String medicationsByClass(String therapeuticClass) =>
      '/medications/by-class/$therapeuticClass';
  static const String prescriptionRequired =
      '/medications/prescription-required';

  // === PATIENT SEARCH ===
  static const String patientSearch = '/patient/search';

  // === ORDERS ===
  static const String orders = '/orders';
  static const String myOrders = '/orders/my-orders';
  static String pharmacyOrders(String pharmacyId) =>
      '/orders/pharmacy-orders/$pharmacyId';
  static String pharmacyStats(String pharmacyId) =>
      '/orders/pharmacy-stats/$pharmacyId';
  static String orderById(String id) => '/orders/$id';
  static String orderStatus(String id) => '/orders/$id/status';

  // === DELIVERIES ===
  static const String myDeliveryStats = '/deliveries/my-stats';
  static const String myDeliveries = '/deliveries/my-deliveries';
  static const String ongoingDeliveries = '/deliveries/my-deliveries/ongoing';
  static const String availableDeliveries = '/deliveries/available';
  static String deliveryStatus(String deliveryId) =>
      '/deliveries/$deliveryId/status';
  static String deliveryProof(String deliveryId) =>
      '/deliveries/$deliveryId/proof';
  static String deliveryLocation(String deliveryId) =>
      '/deliveries/$deliveryId/location';
  static String acceptDelivery(String deliveryId) =>
      '/deliveries/$deliveryId/accept';
  static String deliveryDetails(String deliveryId) => '/deliveries/$deliveryId';
  static const String deliveryStats = '/deliveries/stats';
  static String cancelDelivery(String deliveryId) =>
      '/deliveries/$deliveryId/cancel';
  static const String assignDelivery = '/deliveries/assign';

  // === NOTIFICATIONS ===
  static const String myNotifications = '/notifications/my-notifications';
  static String markNotificationAsRead(String id) => '/notifications/$id/read';

  // === PAYMENTS ===
  static const String payments = '/payments';
  static const String processPayment = '/payments/process';
  static String orderPayment(String orderId) => '/payments/order/$orderId';
  static String paymentReceipt(String paymentId) =>
      '/payments/$paymentId/receipt';

  // === REVIEWS ===
  static const String reviews = '/reviews';
  static String pharmacyReviews(String pharmacyId) =>
      '/reviews/pharmacy/$pharmacyId';
  static String reviewById(String id) => '/reviews/$id';
  static String moderateReview(String id) => '/reviews/$id/status';

  // === PRESCRIPTIONS ===
  static const String prescriptions = '/prescriptions';
  static const String myPrescriptions = '/prescriptions/my-prescriptions';

  // === PAYOUTS ===
  static const String payouts = '/payouts';
  static String pharmacyPayouts(String pharmacyId) =>
      '/payouts/pharmacy/$pharmacyId';

  // === FILES ===
  static const String fileUpload = '/files/upload';
  static String fileUrl(String subdirectory, String filename) =>
      '/files/$subdirectory/$filename';
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
