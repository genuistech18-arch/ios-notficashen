class NotificationModel {
  final String id;
  final String message;
  final bool isRead;
  final DateTime sentAt;
  final DateTime? readAt;
  final String deliveryStatus;

  const NotificationModel({
    required this.id,
    required this.message,
    required this.isRead,
    required this.sentAt,
    required this.readAt,
    required this.deliveryStatus,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      message: json['message'] as String,
      isRead: json['isRead'] as bool,
      sentAt: DateTime.parse(json['sentAt'] as String),
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      deliveryStatus: json['deliveryStatus'] as String,
    );
  }

  NotificationModel copyWith({bool? isRead, DateTime? readAt}) {
    return NotificationModel(
      id: id,
      message: message,
      isRead: isRead ?? this.isRead,
      sentAt: sentAt,
      readAt: readAt ?? this.readAt,
      deliveryStatus: deliveryStatus,
    );
  }
}
