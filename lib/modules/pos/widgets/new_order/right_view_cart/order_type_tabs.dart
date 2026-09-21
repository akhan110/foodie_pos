import 'package:flutter/material.dart';

class OrderTypeTabs extends StatelessWidget {
  const OrderTypeTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _OrderTypeChip(title: 'Dine in', isSelected: true, onTap: () {}),
        _OrderTypeChip(title: 'Takeaway', onTap: () {}),
        _OrderTypeChip(title: 'Delivery', onTap: () {}),
      ],
    );
  }
}

class _OrderTypeChip extends StatelessWidget {
  const _OrderTypeChip({
    required this.title,
    required this.onTap,
    this.isSelected = false,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? colors.onPrimary : colors.onSurface,
          ),
        ),
      ),
    );
  }
}
