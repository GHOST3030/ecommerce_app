import 'package:ecommerce_app/core/supabase/supabase_provider.dart';
import 'package:ecommerce_app/features/wishlist/data/models/wishlist_item_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _kWishlistSelectQuery = '''
  *,
  products!product_id (
    id, category_id, name_en, name_ar, description_en, description_ar,
    base_price, discount_price, images, is_active, is_featured,
    sort_order, created_at
  )
''';

abstract interface class IWishlistRemoteDatasource {
  Future<List<WishlistItemModel>> getWishlist();
  Future<WishlistItemModel> addToWishlist({required String productId});
  Future<void> removeFromWishlist({required String productId});
}

class WishlistRemoteDatasource implements IWishlistRemoteDatasource {
  const WishlistRemoteDatasource(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<List<WishlistItemModel>> getWishlist() async {
    final response = await _supabase
        .from('wishlist')
        .select(_kWishlistSelectQuery)
        .order('created_at', ascending: false);

    return response.map(WishlistItemModel.fromJson).toList();
  }

  @override
  Future<WishlistItemModel> addToWishlist({required String productId}) async {
    final userId = _supabase.auth.currentUser!.id;
    final response = await _supabase
        .from('wishlist')
        .insert(
          {
            'user_id': userId,
            'product_id': productId,
          },
        )
        .select(_kWishlistSelectQuery)
        .single();

    return WishlistItemModel.fromJson(response);
  }

  @override
  Future<void> removeFromWishlist({required String productId}) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase
        .from('wishlist')
        .delete()
        .eq('user_id', userId)
        .eq('product_id', productId);
  }
}

final wishlistRemoteDatasourceProvider =
    Provider<IWishlistRemoteDatasource>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return WishlistRemoteDatasource(supabase);
});
