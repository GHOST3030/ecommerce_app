import 'package:ecommerce_app/core/extensions/context_extension.dart';
import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_spacing.dart';
import 'package:ecommerce_app/features/order/logic/entities/order_entity.dart';
import 'package:flutter/material.dart';

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({
    super.key,
    required this.status,
  });

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          _statusLabel(context, status),
          style: context.textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Color _statusColor(OrderStatus status) {
    return switch (status) {
      OrderStatus.pending => AppColors.warning,
      OrderStatus.confirmed => AppColors.info,
      OrderStatus.processing => AppColors.primary,
      OrderStatus.shipped => AppColors.secondary,
      OrderStatus.delivered => AppColors.success,
      OrderStatus.cancelled => AppColors.error,
      OrderStatus.refunded => Colors.deepPurple,
    };
  }

  String _statusLabel(BuildContext context, OrderStatus status) {
    if (context.isRtl) {
      return switch (status) {
        OrderStatus.pending => 'قيد الانتظار',
        OrderStatus.confirmed => 'تم التأكيد',
        OrderStatus.processing => 'قيد التجهيز',
        OrderStatus.shipped => 'تم الشحن',
        OrderStatus.delivered => 'تم التسليم',
        OrderStatus.cancelled => 'ملغي',
        OrderStatus.refunded => 'مسترد',
      };
    }

    return switch (status) {
      OrderStatus.pending => 'Pending',
      OrderStatus.confirmed => 'Confirmed',
      OrderStatus.processing => 'Processing',
      OrderStatus.shipped => 'Shipped',
      OrderStatus.delivered => 'Delivered',
      OrderStatus.cancelled => 'Cancelled',
      OrderStatus.refunded => 'Refunded',
    };
  }
}
