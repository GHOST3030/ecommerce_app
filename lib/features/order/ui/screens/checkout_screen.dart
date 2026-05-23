import 'package:ecommerce_app/core/extensions/context_extension.dart';
import 'package:ecommerce_app/core/router/app_routes.dart';
import 'package:ecommerce_app/core/theme/app_spacing.dart';
import 'package:ecommerce_app/core/widgets/app_button.dart';
import 'package:ecommerce_app/core/widgets/app_error_widget.dart';
import 'package:ecommerce_app/core/widgets/app_loading.dart';
import 'package:ecommerce_app/features/cart/logic/entities/cart_item_entity.dart';
import 'package:ecommerce_app/features/cart/logic/providers/cart_provider.dart';
import 'package:ecommerce_app/features/cart/logic/states/cart_state.dart';
import 'package:ecommerce_app/features/order/ui/widgets/address_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressLineController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _addressLineController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.isRtl ? 'إتمام الطلب' : 'Checkout'),
      ),
      body: switch (cartState) {
        CartInitial() => const AppLoading(),
        CartLoading() => const AppLoading(),
        CartError(:final message) => AppErrorWidget(
            message: message,
            onRetry: () => ref.read(cartNotifierProvider.notifier).refresh(),
          ),
        CartLoaded(isEmpty: true) => _EmptyCheckout(
            onShopTap: () => context.go(AppRoutes.productList),
          ),
        CartLoaded(:final items) => _CheckoutContent(
            formKey: _formKey,
            items: items,
            fullNameController: _fullNameController,
            phoneController: _phoneController,
            cityController: _cityController,
            addressLineController: _addressLineController,
            notesController: _notesController,
          ),
      },
      bottomNavigationBar: switch (cartState) {
        CartLoaded(isEmpty: false) => _CheckoutBar(
            total: cartState.total,
            onPlaceOrder: _handlePlaceOrder,
          ),
        _ => null,
      },
    );
  }

  void _handlePlaceOrder() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final address = {
      'full_name': _fullNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'city': _cityController.text.trim(),
      'address_line': _addressLineController.text.trim(),
    };
    final notes = _notesController.text.trim();

    // TODO(order): connect to the order placement provider/repository when it
    // is implemented, then clear the cart and navigate to order confirmation.
    debugPrint('Order checkout ready. Address: $address, notes: $notes');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.isRtl
              ? 'واجهة الطلب جاهزة. ربط إنشاء الطلب ما زال مطلوبا.'
              : 'Checkout UI is ready. Order placement still needs integration.',
        ),
      ),
    );
  }
}

class _CheckoutContent extends StatelessWidget {
  const _CheckoutContent({
    required this.formKey,
    required this.items,
    required this.fullNameController,
    required this.phoneController,
    required this.cityController,
    required this.addressLineController,
    required this.notesController,
  });

  final GlobalKey<FormState> formKey;
  final List<CartItemEntity> items;
  final TextEditingController fullNameController;
  final TextEditingController phoneController;
  final TextEditingController cityController;
  final TextEditingController addressLineController;
  final TextEditingController notesController;

  @override
  Widget build(BuildContext context) {
    final total = items.fold(0.0, (sum, item) => sum + (item.lineTotal ?? 0));

    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _Section(
            title: context.isRtl ? 'ملخص السلة' : 'Cart summary',
            child: _CartSummary(items: items),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Section(
            title: context.isRtl ? 'الإجمالي' : 'Total amount',
            child: _AmountRow(
              label: context.isRtl ? 'الإجمالي المستحق' : 'Order total',
              value: '\$${total.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Section(
            title: context.isRtl ? 'الشحن' : 'Shipping',
            child: AddressForm(
              fullNameController: fullNameController,
              phoneController: phoneController,
              cityController: cityController,
              addressLineController: addressLineController,
              notesController: notesController,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({
    required this.total,
    required this.onPlaceOrder,
  });

  final double total;
  final VoidCallback onPlaceOrder;

  @override
  Widget build(BuildContext context) {
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
              _AmountRow(
                label: context.isRtl ? 'الإجمالي' : 'Total',
                value: '\$${total.toStringAsFixed(2)}',
                isTotal: true,
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: context.isRtl ? 'إرسال الطلب' : 'Place order',
                icon: Icons.check_circle_outline_rounded,
                onPressed: onPlaceOrder,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.items});

  final List<CartItemEntity> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _CheckoutItemRow(item: item),
          ),
      ],
    );
  }
}

class _CheckoutItemRow extends StatelessWidget {
  const _CheckoutItemRow({required this.item});

  final CartItemEntity item;

  @override
  Widget build(BuildContext context) {
    final variant = item.variant;
    final locale = Localizations.localeOf(context).languageCode;
    final title = variant?.localizedProductName(locale);
    final price = variant?.effectivePrice ?? 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: const SizedBox(
            width: 48,
            height: 48,
            child: Icon(Icons.shopping_bag_outlined),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title == null || title.isEmpty
                    ? (context.isRtl ? 'منتج' : 'Product')
                    : title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${context.isRtl ? 'الكمية' : 'Qty'}: ${item.quantity}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.theme.hintColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '\$${(price * item.quantity).toStringAsFixed(2)}',
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: context.colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final style = isTotal
        ? context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)
        : context.textTheme.bodyMedium;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}

class _EmptyCheckout extends StatelessWidget {
  const _EmptyCheckout({required this.onShopTap});

  final VoidCallback onShopTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_cart_outlined, size: 56),
            const SizedBox(height: AppSpacing.md),
            Text(
              context.isRtl ? 'سلتك فارغة' : 'Your cart is empty',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.isRtl
                  ? 'أضف منتجات إلى السلة قبل إتمام الطلب.'
                  : 'Add products to your cart before checking out.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.theme.hintColor,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: context.isRtl ? 'متابعة التسوق' : 'Continue shopping',
              icon: Icons.storefront_rounded,
              isExpanded: false,
              onPressed: onShopTap,
            ),
          ],
        ),
      ),
    );
  }
}
