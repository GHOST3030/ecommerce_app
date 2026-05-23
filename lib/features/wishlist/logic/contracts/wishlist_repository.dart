import 'package:ecommerce_app/features/wishlist/logic/entities/wishlist_item_entity.dart';

abstract interface class IWishlistRepository {
  Future<List<WishlistItemEntity>> getWishlist();
  Future<WishlistItemEntity> addToWishlist({required String productId});
  Future<void> removeFromWishlist({required String productId});
}
