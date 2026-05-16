// ─────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────

class CartItemModel {
  const CartItemModel({
    required this.id,
    required this.userId,
    required this.variantId,
    required this.quantity,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String variantId;
  final int quantity;
  final DateTime createdAt;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id:        json['id']         as String,
      userId:    json['user_id']    as String,
      variantId: json['variant_id'] as String,
      quantity:  json['quantity']   as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id':         id,
        'user_id':    userId,
        'variant_id': variantId,
        'quantity':   quantity,
        'created_at': createdAt.toIso8601String(),
      };

  Map<String, dynamic> toInsertJson() => {
        'user_id':    userId,
        'variant_id': variantId,
        'quantity':   quantity,
      };
}
