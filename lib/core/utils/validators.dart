import 'package:easypharma_flutter/core/constants/app_constants.dart';

class Validators {
  // Validation de base
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? 'Le champ $fieldName est obligatoire'
          : 'Ce champ est obligatoire';
    }
    return null;
  }

  // Validation d'email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "L'adresse email est obligatoire.";
    }

    final String trimmedValue = value.trim();

    final RegExp emailRegex = RegExp(
      r'^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}$',

      caseSensitive: false,
    );

    if (!emailRegex.hasMatch(trimmedValue)) {
      return 'Veuillez entrer une adresse email valide.';
    }

    if (trimmedValue.length > 254) {
      return "L'adresse email est trop longue.";
    }

    return null;
  }

  // Validation de mot de passe
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est obligatoire';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Le mot de passe doit contenir au moins ${AppConstants.minPasswordLength} caractères';
    }

    if (value.length > AppConstants.maxPasswordLength) {
      return 'Le mot de passe ne doit pas dépasser ${AppConstants.maxPasswordLength} caractères';
    }

    // Vérification des exigences
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Le mot de passe doit contenir au moins une majuscule';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Le mot de passe doit contenir au moins une minuscule';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Le mot de passe doit contenir au moins un chiffre';
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Le mot de passe doit contenir au moins un caractère spécial';
    }

    return null;
  }

  // Validation de confirmation de mot de passe
  static String? validateConfirmPassword(
    String? value,
    String originalPassword,
  ) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer votre mot de passe';
    }

    if (value != originalPassword) {
      return 'Les mots de passe ne correspondent pas';
    }

    return null;
  }

  // Validation de nom/prénom
  static String? validateName(String? value, {String fieldName = 'nom'}) {
    if (value == null || value.trim().isEmpty) {
      return 'Le $fieldName est obligatoire';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < AppConstants.minNameLength) {
      return 'Le $fieldName doit contenir au moins ${AppConstants.minNameLength} caractères';
    }

    if (trimmedValue.length > AppConstants.maxNameLength) {
      return 'Le $fieldName ne doit pas dépasser ${AppConstants.maxNameLength} caractères';
    }

    final nameRegex = RegExp(r"^[a-zA-ZÀ-ÿ\s'-]+$");
    if (!nameRegex.hasMatch(trimmedValue)) {
      return 'Le $fieldName ne doit contenir que des lettres';
    }

    return null;
  }

  static String? validateFirstName(String? value) {
    return validateName(value, fieldName: 'prénom');
  }

  static String? validateLastName(String? value) {
    return validateName(value, fieldName: 'nom');
  }

  // Validation de téléphone (format Cameroun)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le téléphone est obligatoire';
    }

    if (!RegExp(r'^[0-9+\s-]+$').hasMatch(value)) {
      return 'Le numéro ne doit contenir que des chiffres';
    }

    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleaned.length < AppConstants.minPhoneLength) {
      return 'Le numéro doit contenir au moins ${AppConstants.minPhoneLength} chiffres';
    }

    if (cleaned.length > AppConstants.maxPhoneLength) {
      return 'Le numéro ne doit pas dépasser ${AppConstants.maxPhoneLength} chiffres';
    }

    return null;
  }

  // Validation d'adresse (optionnel)
  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final String trimmedValue = value.trim();

    if (trimmedValue.length < 5) {
      return 'L\'adresse doit contenir au moins 5 caractères';
    }
    if (trimmedValue.length > 100) {
      return "L'adresse est trop longue (maximum 100 caractères).";
    }
    final RegExp addressRegExp = RegExp(r"^[a-zA-Z0-9À-ÿ\s\/\,\';\-\.;]+$");
    if (!addressRegExp.hasMatch(trimmedValue)) {
      return "L'adresse contient des caractères non autorisés.";
    }

    return null;
  }

  // Validation de ville (optionnel)
  static String? validateCity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    // Nettoyage de la valeur pour la validation
    final String trimmedValue = value.trim();

    if (trimmedValue.length < 2) {
      return 'La ville doit contenir au moins 2 caractères valides.';
    }

    final RegExp digitRegExp = RegExp(r'[0-9]');
    if (digitRegExp.hasMatch(trimmedValue)) {
      return 'Le nom de la ville ne peut pas contenir de chiffres.';
    }

    final RegExp validCharRegExp = RegExp(r'[a-zA-ZÀ-ÿ]');
    if (!validCharRegExp.hasMatch(trimmedValue)) {
      return 'Veuillez entrer un nom de ville valide.';
    }

    // Si toutes les vérifications sont passées
    return null;
  }

  // Validation de rôle
  static String? validateRole(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez sélectionner un rôle';
    }

    final validRoles = ['PATIENT', 'PHARMACIST', 'DELIVERY'];
    if (!validRoles.contains(value.toUpperCase())) {
      return 'Rôle invalide';
    }

    return null;
  }
}
