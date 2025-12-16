import 'package:flutter/foundation.dart';

enum UserRole { ADMIN, PHARMACIST, PATIENT, DELIVERY }

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final UserRole role;
  final String address;
  final String city;
  final double? latitude;
  final double? longitude;
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.role,
    this.address = '',
    this.city = '',
    this.latitude,
    this.longitude,
    required this.isActive,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert any value to string
    String safeString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    // Helper function to check if key exists and get value
    String getString(Map<String, dynamic> json, String key) {
      if (!json.containsKey(key)) return '';
      return safeString(json[key]);
    }

    // Helper for DateTime parsing
    DateTime parseDateTime(dynamic value) {
      try {
        if (value == null) return DateTime.now();
        return DateTime.parse(value.toString());
      } catch (e) {
        return DateTime.now();
      }
    }

    // Helper for double parsing
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value);
      }
      return null;
    }

    return User(
      id: safeString(json['id']),
      email: safeString(json['email']),
      firstName: safeString(json['firstName']),
      lastName: safeString(json['lastName']),
      phone: safeString(json['phone']),
      role: _parseRole(safeString(json['role'])),
      // CORRECTION IMPORTANTE : Utilise getString qui vérifie si la clé existe
      address: getString(json, 'address'),
      city: getString(json, 'city'),
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      isActive: json['isActive'] == true,
      isVerified: json['isVerified'] == true,
      createdAt: parseDateTime(json['createdAt']),
      updatedAt: parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'role': role.name,
      'address': address.isEmpty ? null : address,
      'city': city.isEmpty ? null : city,
      'latitude': latitude,
      'longitude': longitude,
      'isActive': isActive,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static UserRole _parseRole(String? role) {
    if (role == null || role.isEmpty) return UserRole.PATIENT;

    switch (role.toUpperCase()) {
      case 'ADMIN':
        return UserRole.ADMIN;
      case 'PHARMACIST':
        return UserRole.PHARMACIST;
      case 'PATIENT':
        return UserRole.PATIENT;
      case 'DELIVERY':
        return UserRole.DELIVERY;
      default:
        return UserRole.PATIENT;
    }
  }

  String get fullName => '$firstName $lastName';

  bool get isPatient => role == UserRole.PATIENT;
  bool get isPharmacist => role == UserRole.PHARMACIST;
  bool get isDelivery => role == UserRole.DELIVERY;
  bool get isAdmin => role == UserRole.ADMIN;

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $fullName, role: $role)';
  }

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    UserRole? role,
    String? address,
    String? city,
    double? latitude,
    double? longitude,
    bool? isActive,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      address: address ?? this.address,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
