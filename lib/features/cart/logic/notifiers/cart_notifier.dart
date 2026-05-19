import 'dart:async';

import 'package:ecommerce_app/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:ecommerce_app/features/cart/logic/entities/cart_item_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartNotifier extends AsyncNotifier<List<CartItemEntity>> {
  @override
  FutureOr<List<CartItemEntity>> build() async {
    final repo = ref.watch(cartRepositoryProvider);
    return repo.getCart();
  }

  Future<void> addToCart({
    required String variantId,
    required int quantity,
  }) async {
    final currentItems = state.valueOrNull ?? [];
    final existing =
        currentItems.where((i) => i.variantId == variantId).firstOrNull;

    if (existing != null) {
      await updateQuantity(
        cartItemId: existing.id,
        quantity: existing.quantity + quantity,
      );
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(cartRepositoryProvider);
      await repo.addToCart(variantId: variantId, quantity: quantity);
      return repo.getCart();
    });
  }

  Future<void> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    if (quantity < 1) {
      await removeFromCart(cartItemId: cartItemId);
      return;
    }

    final currentItems = List<CartItemEntity>.from(state.valueOrNull ?? []);
    final index = currentItems.indexWhere((i) => i.id == cartItemId);

    if (index != -1) {
      currentItems[index] = currentItems[index].copyWith(quantity: quantity);
      state = AsyncData(currentItems);
    }

    try {
      final repo = ref.read(cartRepositoryProvider);
      final updated = await repo.updateQuantity(
        cartItemId: cartItemId,
        quantity: quantity,
      );
      final refreshed = List<CartItemEntity>.from(state.valueOrNull ?? []);
      final i = refreshed.indexWhere((item) => item.id == cartItemId);
      if (i != -1) refreshed[i] = updated;
      state = AsyncData(refreshed);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> removeFromCart({required String cartItemId}) async {
    final currentItems = List<CartItemEntity>.from(state.valueOrNull ?? []);
    final optimistic = currentItems.where((i) => i.id != cartItemId).toList();
    state = AsyncData(optimistic);

    try {
      await ref.read(cartRepositoryProvider).removeFromCart(
            cartItemId: cartItemId,
          );
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> clearCart() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(cartRepositoryProvider).clearCart();
      return <CartItemEntity>[];
    });
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(cartRepositoryProvider).getCart(),
    );
  }
}
