import 'package:ecommerce_app/features/cart/logic/entities/cart_item_entity.dart';

abstract interface class ICartRepository {
  Future<List<CartItemEntity>> getCart();
  Future<CartItemEntity> addToCart({
    required String variantId,
    required int quantity,
  });
  Future<CartItemEntity> updateQuantity({
    required String cartItemId,
    required int quantity,
  });
  Future<void> removeFromCart({required String cartItemId});
  Future<void> clearCart();
}
