import 'dart:async';

import 'package:ecommerce_app/core/extensions/context_extension.dart';
import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_spacing.dart';
import 'package:ecommerce_app/core/theme/app_typography.dart';
import 'package:ecommerce_app/features/product/logic/providers/product_providers.dart';
import 'package:ecommerce_app/features/product/logic/state/product_state.dart';
import 'package:ecommerce_app/features/product/ui/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Pre-populate with any existing query.
    _controller.text = ref.read(productSearchQueryProvider);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  String get _langCode => context.isRtl ? 'ar' : 'en';

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        ref.read(productNotifierProvider.notifier).search(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(productStatusProvider);
    final products = ref.watch(productListProvider);
    final query = ref.watch(productSearchQueryProvider);
    final hasMore = ref.watch(productHasMoreProvider);
    final isLoadingMore = ref.watch(productIsLoadingMoreProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _onChanged,
          textInputAction: TextInputAction.search,
          style: AppTypography.bodyLarge,
          decoration: InputDecoration(
            hintText: _langCode == 'ar'
                ? 'ابحث عن منتجات...'
                : 'Search products...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintStyle: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                _controller.clear();
                ref.read(productNotifierProvider.notifier).search('');
              },
            ),
        ],
      ),
      body: _buildContent(
        status: status,
        products: products,
        query: query,
        hasMore: hasMore,
        isLoadingMore: isLoadingMore,
      ),
    );
  }

  Widget _buildContent({
    required ProductStatus status,
    required products,
    required String query,
    required bool hasMore,
    required bool isLoadingMore,
  }) {
    // Idle: no query entered.
    if (query.isEmpty) {
      return _IdleHint(langCode: _langCode);
    }

    // Loading.
    if (status == ProductStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Empty result.
    if (status == ProductStatus.success && products.isEmpty) {
      return _NoResults(query: query, langCode: _langCode);
    }

    // Results grid.
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.md),
          sliver: SliverGrid(
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.68,
            ),
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => ProductCard(
                product: products[i],
                onTap: () => ctx.push('/product/${products[i].id}'),
                languageCode: _langCode,
              ),
              childCount: products.length,
            ),
          ),
        ),
        if (isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

class _IdleHint extends StatelessWidget {
  const _IdleHint({required this.langCode});

  final String langCode;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.search_rounded,
            size: 72,
            color: AppColors.textSecondaryLight,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            langCode == 'ar'
                ? 'ابدأ الكتابة للبحث'
                : 'Start typing to search',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query, required this.langCode});

  final String query;
  final String langCode;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 72,
            color: AppColors.textSecondaryLight,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            langCode == 'ar'
                ? 'لا توجد نتائج لـ "$query"'
                : 'No results for "$query"',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
