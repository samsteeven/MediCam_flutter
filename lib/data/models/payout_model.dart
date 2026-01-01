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
    return Payout(
      id: json['id'] as String? ?? '',
      pharmacyId: json['pharmacyId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'PENDING',
      bankAccount: json['bankAccount'] as String?,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      processedAt:
          json['processedAt'] != null
              ? DateTime.parse(json['processedAt'] as String)
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
