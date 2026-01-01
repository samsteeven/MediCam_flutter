class Review {
  final String id;
  final String patientId;
  final String pharmacyId;
  final int rating;
  final String comment;
  final String status; // PENDING, APPROVED, REJECTED
  final DateTime createdAt;

  Review({
    required this.id,
    required this.patientId,
    required this.pharmacyId,
    required this.rating,
    required this.comment,
    required this.status,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      pharmacyId: json['pharmacyId'] as String? ?? '',
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'pharmacyId': pharmacyId,
      'rating': rating,
      'comment': comment,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class Prescription {
  final String id;
  final String patientId;
  final String? orderId;
  final String imageUrl;
  final String status; // PENDING, VALIDATED, EXPIRED
  final DateTime createdAt;
  final DateTime? validatedAt;

  Prescription({
    required this.id,
    required this.patientId,
    this.orderId,
    required this.imageUrl,
    required this.status,
    required this.createdAt,
    this.validatedAt,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      orderId: json['orderId'] as String?,
      imageUrl: json['imageUrl'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      validatedAt:
          json['validatedAt'] != null
              ? DateTime.parse(json['validatedAt'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'orderId': orderId,
      'imageUrl': imageUrl,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'validatedAt': validatedAt?.toIso8601String(),
    };
  }
}
