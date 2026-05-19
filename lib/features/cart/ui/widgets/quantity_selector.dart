import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class QuantitySelector extends StatelessWidget {
  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.maxQuantity,
    required this.onDecrement,
    required this.onIncrement,
    this.size = QuantitySelectorSize.medium,
  });

  final int quantity;
  final int maxQuantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final QuantitySelectorSize size;

  @override
  Widget build(BuildContext context) {
    final iconSize = size == QuantitySelectorSize.small
        ? AppSpacing.iconSm
        : AppSpacing.iconMd;
    final buttonSize = size == QuantitySelectorSize.small ? 28.0 : 36.0;
    final fontSize = size == QuantitySelectorSize.small ? 13.0 : 15.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ControlButton(
            icon: Icons.remove,
            iconSize: iconSize,
            buttonSize: buttonSize,
            onPressed: quantity > 1 ? onDecrement : null,
          ),
          SizedBox(
            width: buttonSize,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _ControlButton(
            icon: Icons.add,
            iconSize: iconSize,
            buttonSize: buttonSize,
            onPressed: quantity < maxQuantity ? onIncrement : null,
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.iconSize,
    required this.buttonSize,
    required this.onPressed,
  });

  final IconData icon;
  final double iconSize;
  final double buttonSize;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: iconSize,
        onPressed: onPressed,
        icon: Icon(icon),
        color: onPressed != null
            ? Theme.of(context).colorScheme.primary
            : AppColors.textSecondaryLight.withValues(alpha: 0.4),
      ),
    );
  }
}

enum QuantitySelectorSize { small, medium }
