import 'package:ecommerce_app/core/extensions/context_extension.dart';
import 'package:ecommerce_app/core/router/app_routes.dart';
import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_spacing.dart';
import 'package:ecommerce_app/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({
    super.key,
    this.orderId,
  });

  final String? orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(context.isRtl ? 'تم إنشاء الطلب' : 'Order confirmed'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 38,
                backgroundColor: AppColors.success,
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                context.isRtl ? 'شكرا لطلبك' : 'Thanks for your order',
                textAlign: TextAlign.center,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                context.isRtl
                    ? 'سنرسل لك تحديثات الطلب عند توفرها.'
                    : 'We will share order updates as soon as they are available.',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.theme.hintColor,
                ),
              ),
              if (orderId != null && orderId!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.isRtl ? 'رقم الطلب: ' : 'Order ID: ',
                          style: context.textTheme.bodyMedium,
                        ),
                        Flexible(
                          child: Text(
                            orderId!,
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: context.isRtl ? 'عرض الطلبات' : 'View orders',
                icon: Icons.receipt_long_outlined,
                onPressed: () => context.go(AppRoutes.orders),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: context.isRtl ? 'متابعة التسوق' : 'Continue shopping',
                icon: Icons.storefront_rounded,
                variant: AppButtonVariant.outlined,
                onPressed: () => context.go(AppRoutes.productList),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
