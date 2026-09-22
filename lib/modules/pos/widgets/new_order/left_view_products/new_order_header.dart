import 'package:flutter/material.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/app/widgets/custom_text_widget.dart';
import 'package:foodiepos/modules/pos/controllers/pos_controller.dart';
import 'package:get/get.dart';

class NewOrderHeader extends GetView<PosController> {
  const NewOrderHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextWidget(
                    'New Order',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
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

            // SEARCH BAR
            Container(
              width: 220,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1B202B) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.dividerColor),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, size: 18, color: colors.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: controller.onSearchChanged,
                      style: TextStyle(fontSize: 13, color: colors.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // TOP FILTER CHIPS (All / Popular / Combos)
            const _TopFilterChips(),
          ],
        ),

        const SizedBox(height: 14),

        // CATEGORY CHIPS
        const _CategoryChips(),
      ],
    );
  }
}

class _TopFilterChips extends GetView<PosController> {
  const _TopFilterChips();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Wrap(
        spacing: 8,
        children: [
          _FilterChipItem(
            label: 'All',
            isSelected: controller.selectedTopFilter.value == 'all',
            onTap: () => controller.selectTopFilter('all'),
          ),
          _FilterChipItem(
            label: 'Popular',
            isSelected: controller.selectedTopFilter.value == 'popular',
            onTap: () => controller.selectTopFilter('popular'),
          ),
          _FilterChipItem(
            label: 'Combos',
            isSelected: controller.selectedTopFilter.value == 'combos',
            onTap: () => controller.selectTopFilter('combos'),
          ),
        ],
      ),
    );
  }
}

class _CategoryChips extends GetView<PosController> {
  const _CategoryChips();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedCategory.value;

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChipItem(
              label: 'All Items',
              isSelected: selected == 'all',
              onTap: () => controller.selectCategory('all'),
            ),
            const SizedBox(width: 8),
            ...controller.categories.map((cat) {
              final isSelected = selected == cat.id || selected == cat.name.toLowerCase();
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _FilterChipItem(
                  label: cat.name,
                  isSelected: isSelected,
                  onTap: () => controller.selectCategory(cat.id),
                ),
              );
            }),
          ],
        ),
      );
    });
  }
}

class _FilterChipItem extends StatelessWidget {
  const _FilterChipItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
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
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : theme.dividerColor,
          ),
        ),
        child: CustomTextWidget(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : colors.onSurface,
          ),
        ),
      ),
    );
  }
}
