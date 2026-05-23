enum NotificationType {
  orderConfirmed,
  orderShipped,
  orderDelivered,
  orderCancelled,
  promo,
  general;

  static NotificationType fromString(String value) {
    return switch (value) {
      'order_confirmed' => NotificationType.orderConfirmed,
      'order_shipped' => NotificationType.orderShipped,
      'order_delivered' => NotificationType.orderDelivered,
      'order_cancelled' => NotificationType.orderCancelled,
      'promo' => NotificationType.promo,
      'general' => NotificationType.general,
      _ => throw ArgumentError('Unknown notification type: $value'),
    };
  }

  String toDbString() {
    return switch (this) {
      NotificationType.orderConfirmed => 'order_confirmed',
      NotificationType.orderShipped => 'order_shipped',
      NotificationType.orderDelivered => 'order_delivered',
      NotificationType.orderCancelled => 'order_cancelled',
      NotificationType.promo => 'promo',
      NotificationType.general => 'general',
    };
  }

  bool get isOrderRelated =>
      this == orderConfirmed ||
      this == orderShipped ||
      this == orderDelivered ||
      this == orderCancelled;
}

class NotificationEntity {
  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.orderId,
  });

  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final String? orderId;

  NotificationEntity copyWith({bool? isRead}) {
    return NotificationEntity(
      id: id,
      userId: userId,
      title: title,
      body: body,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      orderId: orderId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'NotificationEntity(id: $id, type: ${type.name}, isRead: $isRead)';
}
