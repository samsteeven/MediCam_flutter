enum PaymentStatus { PENDING, SUCCESS, FAILED, REFUNDED }

class Payment {
  final String id;
  final String orderId;
  final double amount;
  final String method; // e.g., ORANGE_MONEY, WAVE, CARD
  final PaymentStatus status;
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

    String statusRaw =
        safeString(
          json['status'] ??
              json['paymentStatus'] ??
              json['payment_status'] ??
              'PENDING',
        ).toUpperCase();

    PaymentStatus parseStatus(String s) {
      final n = s.replaceAll('-', '_');
      switch (n) {
        case 'PENDING':
          return PaymentStatus.PENDING;
        case 'SUCCESS':
        case 'SUCCESSFUL':
        case 'OK':
          return PaymentStatus.SUCCESS;
        case 'FAILED':
        case 'FAIL':
          return PaymentStatus.FAILED;
        case 'REFUNDED':
          return PaymentStatus.REFUNDED;
        default:
          return PaymentStatus.PENDING;
      }
    }

    return Payment(
      id: safeString(json['id'] ?? json['paymentId'] ?? json['payment_id']),
      orderId: safeString(json['orderId'] ?? json['order_id']),
      amount: parseDouble(json['amount'] ?? json['total'] ?? json['value']),
      method: safeString(
        json['method'] ?? json['paymentMethod'] ?? json['payment_method'],
      ),
      status: parseStatus(statusRaw),
      transactionReference:
          (json['transactionReference'] ??
                  json['transaction_ref'] ??
                  json['txRef'])
              as String?,
      createdAt: parseDate(
        json['createdAt'] ?? json['created_at'] ?? json['timestamp'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'amount': amount,
      'method': method,
      'status': status.toString().split('.').last,
      'transactionReference': transactionReference,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
