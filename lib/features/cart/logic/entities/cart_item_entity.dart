import 'package:ecommerce_app/features/product/logic/entities/product_variant_entity.dart';

class CartItemEntity {
  const CartItemEntity({
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
  final ProductVariantEntity? variant;

  double? get lineTotal {
    if (variant == null) return null;
    return variant!.effectivePrice * quantity;
  }

  CartItemEntity copyWith({
    int? quantity,
    ProductVariantEntity? variant,
  }) {
    return CartItemEntity(
      id:        id,
      userId:    userId,
      variantId: variantId,
      quantity:  quantity ?? this.quantity,
      createdAt: createdAt,
      variant:   variant  ?? this.variant,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'CartItemEntity(id: $id, variantId: $variantId, qty: $quantity)';
}
