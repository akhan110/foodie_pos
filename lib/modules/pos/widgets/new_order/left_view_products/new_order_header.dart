import 'package:flutter/material.dart';
import 'package:foodiepos/app/widgets/custom_text_widget.dart';

class NewOrderHeader extends StatelessWidget {
  const NewOrderHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextWidget(
                    'New Order',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  CustomTextWidget(
                    'Tap products to add them to the order',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            const _TopFilterChips(),
          ],
        ),

        const SizedBox(height: 14),

        const _CategoryChips(),
      ],
    );
  }
}

class _TopFilterChips extends StatelessWidget {
  const _TopFilterChips();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: const [
        _FilterChipItem(label: 'All', isSelected: true),
        _FilterChipItem(label: 'Popular'),
        _FilterChipItem(label: 'Combos'),
      ],
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: const [
        _FilterChipItem(label: 'Burgers', isSelected: true),
        _FilterChipItem(label: 'Chicken'),
        _FilterChipItem(label: 'Pizza'),
        _FilterChipItem(label: 'Sides'),
        _FilterChipItem(label: 'Drinks'),
        _FilterChipItem(label: 'Desserts'),
      ],
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  const _FilterChipItem({required this.label, this.isSelected = false});

  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomTextWidget(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? colors.onPrimary : colors.onSurface,
          ),
        ),
      ),
    );
  }
}
