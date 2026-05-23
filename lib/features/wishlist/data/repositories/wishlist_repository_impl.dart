import 'package:ecommerce_app/core/error/app_exception.dart';
import 'package:ecommerce_app/features/wishlist/data/datasource/wishlist_remote_datasource.dart';
import 'package:ecommerce_app/features/wishlist/data/mappers/wishlist_item_mapper.dart';
import 'package:ecommerce_app/features/wishlist/logic/contracts/wishlist_repository.dart';
import 'package:ecommerce_app/features/wishlist/logic/entities/wishlist_item_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class WishlistRepositoryImpl implements IWishlistRepository {
  const WishlistRepositoryImpl(this._datasource);

  final IWishlistRemoteDatasource _datasource;

  @override
  Future<List<WishlistItemEntity>> getWishlist() async {
    try {
      final models = await _datasource.getWishlist();
      return WishlistItemMapper.toEntityList(models);
    } on supabase.PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<WishlistItemEntity> addToWishlist({
    required String productId,
  }) async {
    try {
      final model = await _datasource.addToWishlist(productId: productId);
      return WishlistItemMapper.toEntity(model);
    } on supabase.PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> removeFromWishlist({required String productId}) async {
    try {
      await _datasource.removeFromWishlist(productId: productId);
    } on supabase.PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }
}

final wishlistRepositoryProvider = Provider<IWishlistRepository>((ref) {
  final datasource = ref.watch(wishlistRemoteDatasourceProvider);
  return WishlistRepositoryImpl(datasource);
});
