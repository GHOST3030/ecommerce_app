import 'package:ecommerce_app/core/extensions/context_extension.dart';
import 'package:ecommerce_app/core/theme/app_spacing.dart';
import 'package:ecommerce_app/features/order/logic/entities/order_entity.dart';
import 'package:ecommerce_app/features/order/ui/widgets/order_items_list.dart';
import 'package:ecommerce_app/features/order/ui/widgets/order_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({
    super.key,
    required this.orderId,
    this.order,
  });

  final String orderId;
  final OrderEntity? order;

  @override
  Widget build(BuildContext context) {
    final currentOrder = order;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.isRtl ? 'تفاصيل الطلب' : 'Order detail'),
      ),
      body: currentOrder == null
          ? _MissingOrderDetail(orderId: orderId)
          : _OrderDetailContent(order: currentOrder),
    );
  }
}

class _OrderDetailContent extends StatelessWidget {
  const _OrderDetailContent({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat.yMMMd().add_jm().format(order.createdAt);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _Section(
          title: context.isRtl ? 'الحالة' : 'Status',
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '#${_shortOrderId(order.id)}',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              OrderStatusBadge(status: order.status),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _Section(
          title: context.isRtl ? 'العناصر' : 'Items',
          child: OrderItemsList(items: order.items),
        ),
        const SizedBox(height: AppSpacing.md),
        _Section(
          title: context.isRtl ? 'عنوان الشحن' : 'Shipping address',
          child: _ShippingAddress(address: order.shippingAddress),
        ),
        const SizedBox(height: AppSpacing.md),
        _Section(
          title: context.isRtl ? 'ملخص الطلب' : 'Order summary',
          child: Column(
            children: [
              _DetailRow(
                label: context.isRtl ? 'تاريخ الإنشاء' : 'Created',
                value: date,
              ),
              const SizedBox(height: AppSpacing.sm),
              _DetailRow(
                label: context.isRtl ? 'عدد العناصر' : 'Items',
                value: order.totalItems.toString(),
              ),
              const SizedBox(height: AppSpacing.sm),
              _DetailRow(
                label: context.isRtl ? 'الإجمالي' : 'Total',
                value: '\$${order.totalAmount.toStringAsFixed(2)}',
                isStrong: true,
              ),
              if (order.notes.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                _DetailRow(
                  label: context.isRtl ? 'ملاحظات' : 'Notes',
                  value: order.notes,
                ),
              ],
            ],
          ),
        ),
        if (order.status.isCancellable) ...[
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.cancel_outlined),
            label: Text(context.isRtl ? 'إلغاء الطلب' : 'Cancel order'),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.isRtl
                ? 'سيتم تفعيل الإلغاء بعد ربط منطق الطلبات.'
                : 'Cancellation will be enabled when order logic is connected.',
            textAlign: TextAlign.center,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.theme.hintColor,
            ),
          ),
        ],
      ],
    );
  }

  String _shortOrderId(String id) {
    if (id.length <= 8) return id;
    return id.substring(0, 8).toUpperCase();
  }
}

class _MissingOrderDetail extends StatelessWidget {
  const _MissingOrderDetail({required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    // TODO(order): fetch the order by orderId when an order provider exists.
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: context.theme.hintColor,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              context.isRtl
                  ? 'تفاصيل الطلب غير متصلة بعد'
                  : 'Order detail is not connected yet',
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.isRtl
                  ? 'سيتم تحميل الطلب $orderId بعد ربط مزود الطلبات.'
                  : 'Order $orderId will load here once the order provider is connected.',
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

class _ShippingAddress extends StatelessWidget {
  const _ShippingAddress({required this.address});

  final Map<String, dynamic> address;

  @override
  Widget build(BuildContext context) {
    final fullName = address['full_name']?.toString() ?? '';
    final phone = address['phone']?.toString() ?? '';
    final city = address['city']?.toString() ?? '';
    final line = address['address_line']?.toString() ?? '';

    if ([fullName, phone, city, line].every((value) => value.isEmpty)) {
      return Text(
        context.isRtl
            ? 'لا يوجد عنوان شحن محفوظ لهذا الطلب.'
            : 'No shipping address is available for this order.',
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.theme.hintColor,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (fullName.isNotEmpty) Text(fullName),
        if (phone.isNotEmpty) Text(phone),
        if (line.isNotEmpty) Text(line),
        if (city.isNotEmpty) Text(city),
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.isStrong = false,
  });

  final String label;
  final String value;
  final bool isStrong;

  @override
  Widget build(BuildContext context) {
    final style = isStrong
        ? context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)
        : context.textTheme.bodyMedium;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: context.textTheme.bodyMedium)),
        const SizedBox(width: AppSpacing.md),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: style,
          ),
        ),
      ],
    );
  }
}
