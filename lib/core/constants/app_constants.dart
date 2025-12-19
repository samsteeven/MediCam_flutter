class AppConstants {
  // Informations de l'application
  static const String appName = 'EasyPharma';
  static const String appVersion = '1.0.0';

  // Clés de stockage
  static const String accessTokenKey = 'easypharma_access_token';
  static const String refreshTokenKey = 'easypharma_refresh_token';
  static const String userDataKey = 'easypharma_user_data';

  // Règles de validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int minPhoneLength = 9;
  static const int maxPhoneLength = 15;

  // Configuration Cameroun
  static const String defaultCountryCode = '+237';
  static const String defaultLanguage = 'fr';
  static const String defaultCurrency = 'XAF';
  static const String defaultCurrencySymbol = 'FCFA';

  // Messages d'erreur
  static const String networkError =
      'Erreur de connexion. Vérifiez votre internet.';
  static const String serverError = 'Erreur du serveur. Réessayez plus tard.';
  static const String unauthorizedError = 'Session expirée. Reconnectez-vous.';
  static const String invalidCredentials = 'Email ou mot de passe incorrect.';

  // Messages de succès
  static const String loginSuccess = 'Connexion réussie !';
  static const String registerSuccess = 'Inscription réussie !';

  // Rôles utilisateur
  static const String rolePatient = 'PATIENT';
  static const String rolePharmacist = 'PHARMACIST';
  static const String roleDelivery = 'DELIVERY';

  // Chemins des images
  static const String logoPath = 'assets/images/logo.png';
  static const String placeholderAvatar =
      'assets/images/avatar_placeholder.png';
}
