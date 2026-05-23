import 'package:ecommerce_app/core/extensions/context_extension.dart';
import 'package:ecommerce_app/core/router/app_routes.dart';
import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_spacing.dart';
import 'package:ecommerce_app/core/widgets/app_button.dart';
import 'package:ecommerce_app/core/widgets/app_error_widget.dart';
import 'package:ecommerce_app/core/widgets/app_loading.dart';
import 'package:ecommerce_app/features/wishlist/logic/providers/wishlist_provider.dart';
import 'package:ecommerce_app/features/wishlist/logic/states/wishlist_state.dart';
import 'package:ecommerce_app/features/wishlist/ui/widgets/wishlist_product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(wishlistStatusProvider) == WishlistStatus.initial) {
        ref.read(wishlistNotifierProvider.notifier).load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wishlistNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.isRtl ? 'المفضلة' : 'Wishlist'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(wishlistNotifierProvider.notifier).refresh(),
        child: switch (state.status) {
          WishlistStatus.initial => const AppLoading(),
          WishlistStatus.loading => const AppLoading(),
          WishlistStatus.failure when state.items.isEmpty => AppErrorWidget(
              message: state.errorMessage ??
                  (context.isRtl
                      ? 'تعذر تحميل المفضلة'
                      : 'Failed to load wishlist'),
              onRetry: () => ref.read(wishlistNotifierProvider.notifier).load(),
            ),
          _ when state.items.isEmpty => _EmptyWishlist(
              onShopTap: () => context.go(AppRoutes.productList),
            ),
          _ => _WishlistGrid(state: state),
        },
      ),
    );
  }
}

class _WishlistGrid extends ConsumerWidget {
  const _WishlistGrid({required this.state});

  final WishlistState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langCode = context.isRtl ? 'ar' : 'en';

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.68,
      ),
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final item = state.items[index];
        return WishlistProductCard(
          item: item,
          languageCode: langCode,
          onTap: () => context.push('/product/${item.productId}'),
          onRemove: () => ref
              .read(wishlistNotifierProvider.notifier)
              .removeProduct(item.productId),
        );
      },
    );
  }
}

class _EmptyWishlist extends StatelessWidget {
  const _EmptyWishlist({required this.onShopTap});

  final VoidCallback onShopTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        SizedBox(height: context.screenHeight * 0.16),
        const Icon(
          Icons.favorite_border_rounded,
          size: 72,
          color: AppColors.textSecondaryLight,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          context.isRtl ? 'لا توجد منتجات مفضلة' : 'No saved products yet',
          textAlign: TextAlign.center,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          context.isRtl
              ? 'اضغط على القلب في المنتجات لحفظها هنا.'
              : 'Tap the heart on products to save them here.',
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.theme.hintColor,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: AppButton(
            label: context.isRtl ? 'تصفح المتجر' : 'Browse shop',
            icon: Icons.storefront_rounded,
            isExpanded: false,
            onPressed: onShopTap,
          ),
        ),
      ],
    );
  }
}
