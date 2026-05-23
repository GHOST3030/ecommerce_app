import 'package:ecommerce_app/core/extensions/context_extension.dart';
import 'package:ecommerce_app/core/router/app_routes.dart';
import 'package:ecommerce_app/core/theme/app_spacing.dart';
import 'package:ecommerce_app/features/order/logic/entities/order_entity.dart';
import 'package:ecommerce_app/features/order/ui/widgets/order_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrdersListScreen extends StatelessWidget {
  const OrdersListScreen({
    super.key,
    this.orders,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<OrderEntity>? orders;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final currentOrders = orders;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.isRtl ? 'طلباتي' : 'My orders'),
      ),
      body: Builder(
        builder: (context) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (errorMessage != null) {
            return _OrderStateMessage(
              icon: Icons.error_outline_rounded,
              title: context.isRtl
                  ? 'تعذر تحميل الطلبات'
                  : 'Could not load orders',
              message: errorMessage!,
            );
          }

          if (currentOrders == null) {
            // TODO(order): watch the order list provider here when it exists.
            return _OrderStateMessage(
              icon: Icons.receipt_long_outlined,
              title: context.isRtl
                  ? 'سجل الطلبات غير متصل بعد'
                  : 'Orders are not connected yet',
              message: context.isRtl
                  ? 'سيتم عرض طلباتك هنا بعد ربط طبقة بيانات الطلبات.'
                  : 'Your orders will appear here once the order data layer is connected.',
            );
          }

          if (currentOrders.isEmpty) {
            return _OrderStateMessage(
              icon: Icons.shopping_bag_outlined,
              title: context.isRtl ? 'لا توجد طلبات' : 'No orders yet',
              message: context.isRtl
                  ? 'طلباتك المستقبلية ستظهر هنا.'
                  : 'Future orders will appear here.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: currentOrders.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final order = currentOrders[index];
              return OrderCard(
                order: order,
                onTap: () => context.push(
                  AppRoutes.orderDetailPath(order.id),
                  extra: order,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _OrderStateMessage extends StatelessWidget {
  const _OrderStateMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: context.theme.hintColor),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.theme.hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
