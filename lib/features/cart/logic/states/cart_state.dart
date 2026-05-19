import 'package:ecommerce_app/features/cart/logic/entities/cart_item_entity.dart';

sealed class CartState {
  const CartState();
}

final class CartInitial extends CartState {
  const CartInitial();
}

final class CartLoading extends CartState {
  const CartLoading();
}

final class CartLoaded extends CartState {
  const CartLoaded(this.items);

  final List<CartItemEntity> items;

  bool get isEmpty => items.isEmpty;
  int get itemCount => items.length;
  int get totalQuantity => items.fold(0, (sum, i) => sum + i.quantity);
  double get total => items.fold(0.0, (sum, i) => sum + (i.lineTotal ?? 0.0));
}

final class CartError extends CartState {
  const CartError(this.message);

  final String message;
}
