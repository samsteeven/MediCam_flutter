class Payment {
  final String id;
  final String orderId;
  final double amount;
  final String method; // e.g., ORANGE_MONEY, WAVE, CARD
  final String status; // PENDING, SUCCESSFUL, FAILED
  final String? transactionReference;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.method,
    required this.status,
    this.transactionReference,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      method: json['method'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      transactionReference: json['transactionReference'] as String?,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'amount': amount,
      'method': method,
      'status': status,
      'transactionReference': transactionReference,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
