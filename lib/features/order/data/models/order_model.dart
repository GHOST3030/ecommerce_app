// ─────────────────────────────────────────────────────────────
// ORDER ITEM MODEL
// ─────────────────────────────────────────────────────────────

class OrderItemModel {
  const OrderItemModel({
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

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id:        json['id']         as String,
      orderId:   json['order_id']   as String,
      variantId: json['variant_id'] as String,
      quantity:  json['quantity']   as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id':         id,
        'order_id':   orderId,
        'variant_id': variantId,
        'quantity':   quantity,
        'unit_price': unitPrice,
        'created_at': createdAt.toIso8601String(),
      };

  Map<String, dynamic> toInsertJson() => {
        'order_id':   orderId,
        'variant_id': variantId,
        'quantity':   quantity,
        'unit_price': unitPrice,
      };
}

// ─────────────────────────────────────────────────────────────
// ORDER MODEL
// ─────────────────────────────────────────────────────────────

class OrderModel {
  const OrderModel({
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
  final String status; // raw DB enum string
  final double totalAmount;
  final Map<String, dynamic> shippingAddress;
  final String notes;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['order_items'] as List<dynamic>? ?? [];
    return OrderModel(
      id:              json['id']               as String,
      userId:          json['user_id']          as String,
      status:          json['status']           as String,
      totalAmount:    (json['total_amount']      as num).toDouble(),
      shippingAddress: (json['shipping_address'] as Map<String, dynamic>?) ?? {},
      notes:           json['notes']            as String? ?? '',
      createdAt:       DateTime.parse(json['created_at'] as String),
      items: rawItems
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id':               id,
        'user_id':          userId,
        'status':           status,
        'total_amount':     totalAmount,
        'shipping_address': shippingAddress,
        'notes':            notes,
        'created_at':       createdAt.toIso8601String(),
      };

  Map<String, dynamic> toInsertJson() => {
        'user_id':          userId,
        'total_amount':     totalAmount,
        'shipping_address': shippingAddress,
        'notes':            notes,
      };
}
