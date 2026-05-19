import 'package:ecommerce_app/core/error/app_exception.dart';
import 'package:ecommerce_app/features/cart/data/datasource/cart_remote_datasource.dart';
import 'package:ecommerce_app/features/cart/data/mappers/cart_item_mapper.dart';
import 'package:ecommerce_app/features/cart/logic/contracts/cart_repository.dart';
import 'package:ecommerce_app/features/cart/logic/entities/cart_item_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class CartRepositoryImpl implements ICartRepository {
  CartRepositoryImpl(this._datasource);

  final ICartRemoteDatasource _datasource;

  @override
  Future<List<CartItemEntity>> getCart() async {
    try {
      final models = await _datasource.getCart();
      return CartItemMapper.toEntityList(models);
    } on supabase.PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<CartItemEntity> addToCart({
    required String variantId,
    required int quantity,
  }) async {
    try {
      final model = await _datasource.addToCart(
        variantId: variantId,
        quantity: quantity,
      );
      return CartItemMapper.toEntity(model);
    } on supabase.PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<CartItemEntity> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      final model = await _datasource.updateQuantity(
        cartItemId: cartItemId,
        quantity: quantity,
      );
      return CartItemMapper.toEntity(model);
    } on supabase.PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> removeFromCart({required String cartItemId}) async {
    try {
      await _datasource.removeFromCart(cartItemId: cartItemId);
    } on supabase.PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await _datasource.clearCart();
    } on supabase.PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }
}

final cartRepositoryProvider = Provider<ICartRepository>((ref) {
  final datasource = ref.watch(cartRemoteDatasourceProvider);
  return CartRepositoryImpl(datasource);
});
