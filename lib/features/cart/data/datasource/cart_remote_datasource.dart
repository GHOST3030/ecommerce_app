import 'package:ecommerce_app/core/supabase/supabase_provider.dart';
import 'package:ecommerce_app/features/cart/data/models/cart_item_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _kCartSelectQuery = '''
  *,
  product_variants!variant_id (
    id, product_id, sku, size, color_en, color_ar, color_hex,
    price, discount_price, stock, is_active, sort_order, created_at,
    products!product_id (
      name_en, name_ar, images
    )
  )
''';

abstract interface class ICartRemoteDatasource {
  Future<List<CartItemModel>> getCart();
  Future<CartItemModel> addToCart({
    required String variantId,
    required int quantity,
  });
  Future<CartItemModel> updateQuantity({
    required String cartItemId,
    required int quantity,
  });
  Future<void> removeFromCart({required String cartItemId});
  Future<void> clearCart();
}

class CartRemoteDatasource implements ICartRemoteDatasource {
  CartRemoteDatasource(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<List<CartItemModel>> getCart() async {
    final response = await _supabase
        .from('cart_items')
        .select(_kCartSelectQuery)
        .order('created_at', ascending: false);

    return response.map(CartItemModel.fromJson).toList();
  }

  @override
  Future<CartItemModel> addToCart({
    required String variantId,
    required int quantity,
  }) async {
    final userId = _supabase.auth.currentUser!.id;
    final response = await _supabase
        .from('cart_items')
        .upsert(
          {
            'user_id': userId,
            'variant_id': variantId,
            'quantity': quantity,
          },
          onConflict: 'user_id,variant_id',
        )
        .select(_kCartSelectQuery)
        .single();

    return CartItemModel.fromJson(response);
  }

  @override
  Future<CartItemModel> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    final response = await _supabase
        .from('cart_items')
        .update({'quantity': quantity})
        .eq('id', cartItemId)
        .select(_kCartSelectQuery)
        .single();

    return CartItemModel.fromJson(response);
  }

  @override
  Future<void> removeFromCart({required String cartItemId}) async {
    await _supabase.from('cart_items').delete().eq('id', cartItemId);
  }

  @override
  Future<void> clearCart() async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase.from('cart_items').delete().eq('user_id', userId);
  }
}

final cartRemoteDatasourceProvider = Provider<ICartRemoteDatasource>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return CartRemoteDatasource(supabase);
});
