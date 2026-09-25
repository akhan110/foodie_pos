import 'package:flutter/material.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/modules/pos/controllers/pos_controller.dart';
import 'package:get/get.dart';

class OrderTypeTabs extends GetView<PosController> {
  const OrderTypeTabs({super.key});

  static const List<String> _types = ['Dine in', 'Takeaway', 'Delivery'];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentType = controller.orderType.value.toLowerCase();

      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _types.map((type) {
          final isSelected = currentType == type.toLowerCase() ||
              (type == 'Dine in' && currentType == 'dine in');

          return _OrderTypeChip(
            title: type,
            isSelected: isSelected,
            onTap: () {
              controller.orderType.value = type;
            },
          );
        }).toList(),
      );
    });
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : theme.dividerColor.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Text(
          title,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : colors.onSurface,
          ),
        ),
      ),
    );
  }
}
