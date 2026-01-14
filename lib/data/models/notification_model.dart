class NotificationDTO {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String? type; // Par exemple: 'ORDER_STATUS', 'DELIVERY_ASSIGNED', etc.
  final String? referenceId; // ID lié à la notification (ex: orderId)

  NotificationDTO({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.type,
    this.referenceId,
  });

  factory NotificationDTO.fromJson(Map<String, dynamic> json) {
    String safeString(dynamic v) => v == null ? '' : v.toString();
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    String s(dynamic v) => v == null ? '' : v.toString();
    DateTime pd(dynamic v) {
      if (v == null) return DateTime.now();
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    return NotificationDTO(
      id: s(json['id'] ?? json['notificationId'] ?? json['notification_id']),
      title: s(json['title'] ?? json['subject']),
      message: s(json['message'] ?? json['body'] ?? json['content']),
      createdAt: pd(
        json['createdAt'] ?? json['created_at'] ?? json['timestamp'],
      ),
      isRead: (json['isRead'] ?? json['read'] ?? false) == true,
      type: (json['type'] ?? json['notificationType']) as String?,
      referenceId:
          (json['referenceId'] ?? json['reference_id'] ?? json['orderId'])
              as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'type': type,
      'referenceId': referenceId,
    };
  }

  NotificationDTO copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? createdAt,
    bool? isRead,
    String? type,
    String? referenceId,
  }) {
    return NotificationDTO(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      referenceId: referenceId ?? this.referenceId,
    );
  }
}
