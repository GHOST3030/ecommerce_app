import 'package:ecommerce_app/features/product/logic/entities/product_entity.dart';

class WishlistItemEntity {
  const WishlistItemEntity({
    required this.id,
    required this.userId,
    required this.productId,
    required this.createdAt,
    this.product,
  });

  final String id;
  final String userId;
  final String productId;
  final DateTime createdAt;
  final ProductEntity? product;

  WishlistItemEntity copyWith({ProductEntity? product}) {
    return WishlistItemEntity(
      id:        id,
      userId:    userId,
      productId: productId,
      createdAt: createdAt,
      product:   product ?? this.product,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WishlistItemEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'WishlistItemEntity(id: $id, productId: $productId)';
}
