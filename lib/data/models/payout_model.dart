class Payout {
  final String id;
  final String pharmacyId;
  final double amount;
  final String status; // PENDING, PROCESSED, FAILED
  final String? bankAccount;
  final DateTime createdAt;
  final DateTime? processedAt;

  Payout({
    required this.id,
    required this.pharmacyId,
    required this.amount,
    required this.status,
    this.bankAccount,
    required this.createdAt,
    this.processedAt,
  });

  factory Payout.fromJson(Map<String, dynamic> json) {
    String safeString(dynamic v) => v == null ? '' : v.toString();
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return Payout(
      id: safeString(json['id'] ?? json['payoutId'] ?? json['payout_id']),
      pharmacyId: safeString(json['pharmacyId'] ?? json['pharmacy_id']),
      amount: parseDouble(json['amount'] ?? json['value']),
      status: safeString(json['status'] ?? 'PENDING'),
      bankAccount: (json['bankAccount'] ?? json['bank_account']) as String?,
      createdAt: parseDate(json['createdAt'] ?? json['created_at']),
      processedAt:
          json['processedAt'] != null
              ? parseDate(json['processedAt'] ?? json['processed_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pharmacyId': pharmacyId,
      'amount': amount,
      'status': status,
      'bankAccount': bankAccount,
      'createdAt': createdAt.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
    };
  }
}
