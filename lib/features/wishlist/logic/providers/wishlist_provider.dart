import 'package:ecommerce_app/features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'package:ecommerce_app/features/wishlist/logic/entities/wishlist_item_entity.dart';
import 'package:ecommerce_app/features/wishlist/logic/notifiers/wishlist_notifier.dart';
import 'package:ecommerce_app/features/wishlist/logic/states/wishlist_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final wishlistNotifierProvider =
    StateNotifierProvider<WishlistNotifier, WishlistState>((ref) {
  final repository = ref.watch(wishlistRepositoryProvider);
  return WishlistNotifier(repository);
});

final wishlistItemsProvider = Provider<List<WishlistItemEntity>>((ref) {
  return ref.watch(wishlistNotifierProvider).items;
});

final wishlistProductIdsProvider = Provider<Set<String>>((ref) {
  return ref.watch(wishlistNotifierProvider).productIds;
});

final wishlistStatusProvider = Provider<WishlistStatus>((ref) {
  return ref.watch(wishlistNotifierProvider).status;
});

final wishlistErrorProvider = Provider<String?>((ref) {
  return ref.watch(wishlistNotifierProvider).errorMessage;
});

final wishlistCountProvider = Provider<int>((ref) {
  return ref.watch(wishlistNotifierProvider).items.length;
});
