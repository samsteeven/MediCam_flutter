class Review {
  final String id;
  final String patientId;
  final String? patientName;
  final String pharmacyId;
  final int rating;
  final String comment;
  final int? courierRating;
  final String? courierComment;
  final String status; // PENDING, APPROVED, REJECTED
  final DateTime createdAt;

  Review({
    required this.id,
    required this.patientId,
    this.patientName,
    required this.pharmacyId,
    required this.rating,
    required this.comment,
    this.courierRating,
    this.courierComment,
    required this.status,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    String safeString(dynamic v) => v == null ? '' : v.toString();
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    return Review(
      id: safeString(json['id'] ?? json['reviewId'] ?? json['review_id']),
      patientId: safeString(json['patientId'] ?? json['patient_id']),
      patientName:
          json['patientName'] as String? ?? json['patient_name'] as String?,
      pharmacyId: safeString(json['pharmacyId'] ?? json['pharmacy_id']),
      rating:
          (json['pharmacyRating'] as num?)?.toInt() ??
          (json['pharmacy_rating'] as num?)?.toInt() ??
          (json['rating'] as num?)?.toInt() ??
          (json['score'] as num?)?.toInt() ??
          0,
      comment: safeString(
        json['pharmacyComment'] ??
            json['pharmacy_comment'] ??
            json['comment'] ??
            json['message'] ??
            json['text'] ??
            '',
      ),
      courierRating:
          (json['courierRating'] as num?)?.toInt() ??
          (json['courier_rating'] as num?)?.toInt(),
      courierComment:
          json['courierComment'] as String? ??
          json['courier_comment'] as String?,
      status: safeString(json['status'] ?? 'PENDING'),
      createdAt: parseDate(json['createdAt'] ?? json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'pharmacyId': pharmacyId,
      'rating': rating,
      'comment': comment,
      'courierRating': courierRating,
      'courierComment': courierComment,
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
    String safeString(dynamic v) => v == null ? '' : v.toString();
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    return Prescription(
      id: safeString(
        json['id'] ?? json['prescriptionId'] ?? json['prescription_id'],
      ),
      patientId: safeString(json['patientId'] ?? json['patient_id']),
      orderId: (json['orderId'] ?? json['order_id']) as String?,
      imageUrl: safeString(
        json['imageUrl'] ?? json['image_url'] ?? json['url'] ?? '',
      ),
      status: safeString(json['status'] ?? 'PENDING'),
      createdAt: parseDate(json['createdAt'] ?? json['created_at']),
      validatedAt:
          json['validatedAt'] != null
              ? parseDate(json['validatedAt'] ?? json['validated_at'])
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
