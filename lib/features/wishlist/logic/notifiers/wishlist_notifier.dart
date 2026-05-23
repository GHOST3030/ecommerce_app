import 'package:ecommerce_app/features/wishlist/logic/contracts/wishlist_repository.dart';
import 'package:ecommerce_app/features/wishlist/logic/states/wishlist_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WishlistNotifier extends StateNotifier<WishlistState> {
  WishlistNotifier(this._repository) : super(const WishlistState.initial());

  final IWishlistRepository _repository;

  Future<void> load() async {
    if (state.isLoading) return;

    state = state.copyWith(
      status:
          state.isInitial ? WishlistStatus.loading : WishlistStatus.refreshing,
      clearError: true,
    );

    try {
      final items = await _repository.getWishlist();
      state = state.copyWith(
        status: WishlistStatus.success,
        items: items,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: WishlistStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() => load();

  Future<void> toggleProduct(String productId) async {
    if (state.isMutating(productId)) return;

    final wasWishlisted = state.containsProduct(productId);
    final previousItems = state.items;
    final previousMutating = state.mutatingProductIds;

    state = state.copyWith(
      items: wasWishlisted
          ? state.items.where((item) => item.productId != productId).toList()
          : state.items,
      mutatingProductIds: {...previousMutating, productId},
      clearError: true,
    );

    try {
      if (wasWishlisted) {
        await _repository.removeFromWishlist(productId: productId);
        state = state.copyWith(
          status: WishlistStatus.success,
          mutatingProductIds: _withoutMutating(productId),
        );
        return;
      }

      final item = await _repository.addToWishlist(productId: productId);
      final withoutDuplicate = state.items
          .where((existing) => existing.productId != productId)
          .toList();
      state = state.copyWith(
        status: WishlistStatus.success,
        items: [item, ...withoutDuplicate],
        mutatingProductIds: _withoutMutating(productId),
      );
    } catch (e) {
      state = state.copyWith(
        status: WishlistStatus.failure,
        items: previousItems,
        mutatingProductIds: previousMutating,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> removeProduct(String productId) async {
    if (!state.containsProduct(productId)) return;
    await toggleProduct(productId);
  }

  Set<String> _withoutMutating(String productId) {
    return {...state.mutatingProductIds}..remove(productId);
  }
}
