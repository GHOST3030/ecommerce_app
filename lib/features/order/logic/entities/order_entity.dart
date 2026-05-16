enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded;

  static OrderStatus fromString(String value) {
    return switch (value) {
      'pending'    => OrderStatus.pending,
      'confirmed'  => OrderStatus.confirmed,
      'processing' => OrderStatus.processing,
      'shipped'    => OrderStatus.shipped,
      'delivered'  => OrderStatus.delivered,
      'cancelled'  => OrderStatus.cancelled,
      'refunded'   => OrderStatus.refunded,
      _            => throw ArgumentError('Unknown order status: $value'),
    };
  }

  String toDbString() => name;

  bool get isActive =>
      this == pending ||
      this == confirmed ||
      this == processing ||
      this == shipped;

  bool get isCancellable =>
      this == pending || this == confirmed;

  bool get isTerminal =>
      this == delivered ||
      this == cancelled ||
      this == refunded;
}

// ─────────────────────────────────────────────────────────────

class OrderItemEntity {
  const OrderItemEntity({
    required this.id,
    required this.orderId,
    required this.variantId,
    required this.quantity,
    required this.unitPrice,
    required this.createdAt,
  });

  final String id;
  final String orderId;
  final String variantId;
  final int quantity;
  final double unitPrice;
  final DateTime createdAt;

  double get lineTotal => unitPrice * quantity;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderItemEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ─────────────────────────────────────────────────────────────

class OrderEntity {
  const OrderEntity({
    required this.id,
    required this.userId,
    required this.status,
    required this.totalAmount,
    required this.shippingAddress,
    required this.notes,
    required this.createdAt,
    this.items = const [],
  });

  final String id;
  final String userId;
  final OrderStatus status;
  final double totalAmount;
  final Map<String, dynamic> shippingAddress;
  final String notes;
  final DateTime createdAt;

  /// Eagerly-loaded line items — populated when fetched with a join.
  final List<OrderItemEntity> items;

  // ── Computed helpers ─────────────────────────────────────

  int get totalItems => items.fold(0, (sum, i) => sum + i.quantity);

  // ── Equality / copy ──────────────────────────────────────

  OrderEntity copyWith({
    OrderStatus? status,
    List<OrderItemEntity>? items,
  }) {
    return OrderEntity(
      id:              id,
      userId:          userId,
      status:          status  ?? this.status,
      totalAmount:     totalAmount,
      shippingAddress: shippingAddress,
      notes:           notes,
      createdAt:       createdAt,
      items:           items   ?? this.items,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'OrderEntity(id: $id, status: ${status.name}, total: $totalAmount)';
}
