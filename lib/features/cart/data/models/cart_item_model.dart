import 'package:ecommerce_app/features/product/data/models/product_variant_model.dart';

class CartItemModel {
  const CartItemModel({
    required this.id,
    required this.userId,
    required this.variantId,
    required this.quantity,
    required this.createdAt,
    this.variant,
  });

  final String id;
  final String userId;
  final String variantId;
  final int quantity;
  final DateTime createdAt;
  final ProductVariantModel? variant;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final variantJson = json['product_variants'] as Map<String, dynamic>?;
    return CartItemModel(
      id:        json['id']         as String,
      userId:    json['user_id']    as String,
      variantId: json['variant_id'] as String,
      quantity:  json['quantity']   as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      variant: variantJson != null
          ? ProductVariantModel.fromJson(variantJson)
          : null,
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
