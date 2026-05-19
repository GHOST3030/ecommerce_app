import 'package:ecommerce_app/core/extensions/context_extension.dart';
import 'package:ecommerce_app/core/theme/app_spacing.dart';
import 'package:ecommerce_app/core/widgets/app_button.dart';
import 'package:ecommerce_app/features/cart/logic/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartSummaryCard extends ConsumerWidget {
  const CartSummaryCard({super.key, required this.onCheckout});

  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(cartTotalProvider);
    final itemCount = ref.watch(cartQuantityCountProvider);

    return SafeArea(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: context.colorScheme.outline.withValues(alpha: 0.15),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${context.l10n.cartSubtotal} ($itemCount)',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.theme.hintColor,
                    ),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: context.l10n.checkout,
                onPressed: itemCount > 0 ? onCheckout : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
