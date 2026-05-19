import 'package:ecommerce_app/core/extensions/context_extension.dart';
import 'package:ecommerce_app/core/router/app_routes.dart';
import 'package:ecommerce_app/core/theme/app_spacing.dart';
import 'package:ecommerce_app/core/widgets/app_error_widget.dart';
import 'package:ecommerce_app/core/widgets/app_loading.dart';
import 'package:ecommerce_app/features/cart/logic/entities/cart_item_entity.dart';
import 'package:ecommerce_app/features/cart/logic/providers/cart_provider.dart';
import 'package:ecommerce_app/features/cart/logic/states/cart_state.dart';
import 'package:ecommerce_app/features/cart/ui/widgets/cart_item_tile.dart';
import 'package:ecommerce_app/features/cart/ui/widgets/cart_summary_card.dart';
import 'package:ecommerce_app/features/cart/ui/widgets/empty_cart_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartStateProvider);

    return Scaffold(
      appBar: _buildAppBar(context, ref, cartState),
      body: switch (cartState) {
        CartInitial() => const AppLoading(),
        CartLoading() => const AppLoading(),
        CartError(:final message) => AppErrorWidget(
            message: message,
            onRetry: () => ref.read(cartNotifierProvider.notifier).refresh(),
          ),
        CartLoaded(isEmpty: true) => const EmptyCartView(),
        CartLoaded(:final items) => _CartItemList(items: items),
      },
      bottomNavigationBar: switch (cartState) {
        CartLoaded(isEmpty: false) => CartSummaryCard(
            onCheckout: () => context.push(AppRoutes.checkout),
          ),
        _ => null,
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    CartState cartState,
  ) {
    final itemCount = ref.watch(cartQuantityCountProvider);

    return AppBar(
      title: Text(
        itemCount > 0 ? '${context.l10n.cart} ($itemCount)' : context.l10n.cart,
      ),
      actions: [
        if (cartState is CartLoaded && !cartState.isEmpty)
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: context.l10n.clearCart,
            onPressed: () => _confirmClearCart(context, ref),
          ),
      ],
    );
  }

  Future<void> _confirmClearCart(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.clearCart),
        content: Text(context.l10n.clearCartConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              context.l10n.confirm,
              style: TextStyle(
                color: Theme.of(ctx).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(cartNotifierProvider.notifier).clearCart();
    }
  }
}

class _CartItemList extends StatelessWidget {
  const _CartItemList({required this.items});

  final List<CartItemEntity> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        indent: AppSpacing.md,
        endIndent: AppSpacing.md,
      ),
      itemBuilder: (_, index) => CartItemTile(item: items[index]),
    );
  }
}
