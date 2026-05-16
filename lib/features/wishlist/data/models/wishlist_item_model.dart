// ─────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────

class WishlistItemModel {
  const WishlistItemModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String productId;
  final DateTime createdAt;

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    return WishlistItemModel(
      id:        json['id']         as String,
      userId:    json['user_id']    as String,
      productId: json['product_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id':         id,
        'user_id':    userId,
        'product_id': productId,
        'created_at': createdAt.toIso8601String(),
      };

  Map<String, dynamic> toInsertJson() => {
        'user_id':    userId,
        'product_id': productId,
      };
}
