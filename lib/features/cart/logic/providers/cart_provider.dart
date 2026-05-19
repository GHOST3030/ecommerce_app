import 'package:ecommerce_app/features/cart/logic/entities/cart_item_entity.dart';
import 'package:ecommerce_app/features/cart/logic/notifiers/cart_notifier.dart';
import 'package:ecommerce_app/features/cart/logic/states/cart_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cartNotifierProvider =
    AsyncNotifierProvider<CartNotifier, List<CartItemEntity>>(
  CartNotifier.new,
);

final cartStateProvider = Provider<CartState>((ref) {
  final asyncCart = ref.watch(cartNotifierProvider);

  if (asyncCart.isLoading) return const CartLoading();

  if (asyncCart.hasError) {
    return CartError(asyncCart.error.toString());
  }

  if (asyncCart.hasValue) {
    return CartLoaded(asyncCart.value!);
  }

  return const CartInitial();
});

final cartTotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartNotifierProvider).valueOrNull ?? [];
  return items.fold(0.0, (sum, item) => sum + (item.lineTotal ?? 0.0));
});

final cartItemCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartNotifierProvider).valueOrNull ?? [];
  return items.length;
});

final cartQuantityCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartNotifierProvider).valueOrNull ?? [];
  return items.fold(0, (sum, item) => sum + item.quantity);
});
