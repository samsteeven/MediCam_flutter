
enum UserRole {
  SUPER_ADMIN,
  PHARMACY_ADMIN,
  PHARMACY_EMPLOYEE,
  PATIENT,
  DELIVERY,
}

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
  final String? pharmacyId;
  final String? pharmacyName;

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
    this.pharmacyId,
    this.pharmacyName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String s(dynamic v) => v == null ? '' : v.toString();

    double? pd(dynamic v) {
      if (v == null) return null;
      try {
        return double.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    DateTime pdt(dynamic v) {
      if (v == null) return DateTime.now();
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    UserRole parseRole(dynamic v) {
      final role = s(v).toUpperCase();
      switch (role) {
        case 'SUPER_ADMIN':
          return UserRole.SUPER_ADMIN;
        case 'PHARMACY_ADMIN':
          return UserRole.PHARMACY_ADMIN;
        case 'PHARMACY_EMPLOYEE':
          return UserRole.PHARMACY_EMPLOYEE;
        case 'DELIVERY':
          return UserRole.DELIVERY;
        case 'PATIENT':
        default:
          return UserRole.PATIENT;
      }
    }

    return User(
      id: s(json['id'] ?? json['userId'] ?? json['user_id']),
      email: s(json['email'] ?? json['mail'] ?? ''),
      firstName: s(json['firstName'] ?? json['first_name'] ?? ''),
      lastName: s(json['lastName'] ?? json['last_name'] ?? ''),
      phone: s(json['phone'] ?? json['telephone'] ?? ''),
      role: parseRole(json['role'] ?? json['userRole']),
      address: s(json['address'] ?? ''),
      city: s(json['city'] ?? ''),
      latitude: pd(json['latitude'] ?? json['lat']),
      longitude: pd(json['longitude'] ?? json['lon'] ?? json['lng']),
      isActive: (json['isActive'] ?? json['active'] ?? false) == true,
      isVerified: (json['isVerified'] ?? json['verified'] ?? false) == true,
      createdAt: pdt(json['createdAt'] ?? json['created_at']),
      pharmacyId: s(
        json['pharmacyId'] ?? json['pharmacy_id'] ?? json['pharmacyId'],
      ),
      pharmacyName: s(
        json['pharmacyName'] ?? json['pharmacy_name'] ?? json['pharmacyName'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'role': role.toString().split('.').last,
      'address': address.isEmpty ? null : address,
      'city': city.isEmpty ? null : city,
      'latitude': latitude,
      'longitude': longitude,
      'isActive': isActive,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'pharmacyId': pharmacyId,
      'pharmacyName': pharmacyName,
    };
  }

  String get fullName => '$firstName $lastName'.trim();

  bool get isPatient => role == UserRole.PATIENT;
  bool get isPharmacist =>
      role == UserRole.PHARMACY_EMPLOYEE || role == UserRole.PHARMACY_ADMIN;
  bool get isDelivery => role == UserRole.DELIVERY;
  bool get isAdmin => role == UserRole.SUPER_ADMIN;

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
    String? pharmacyId,
    String? pharmacyName,
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
      pharmacyId: pharmacyId ?? this.pharmacyId,
      pharmacyName: pharmacyName ?? this.pharmacyName,
    );
  }
}
