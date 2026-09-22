import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/app/widgets/custom_text_widget.dart';
import 'package:foodiepos/modules/menu/controllers/menu_management_controller.dart';
import 'package:foodiepos/modules/pos/model/product_model.dart';
import 'package:get/get.dart';

class MenuManagementView extends StatelessWidget {
  const MenuManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MenuManagementController());
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF10151E) : const Color(0xFFF7F8FA),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================================
          // 1. TOP HEADER ROW: Title + Add New Item Button
          // ============================================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextWidget(
                    'Menu Management',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  CustomTextWidget(
                    'Add, edit and organize your menu items, prices and categories.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => controller.startNewProduct(),
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: const Text(
                  'Add New Item',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ============================================================
          // 2. MAIN 2-COLUMN SECTION: (Left List & Right Editor)
          // ============================================================
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ======================================================
                // LEFT PANEL: Filter Toolbar + Products Catalog List
                // ======================================================
                Expanded(
                  flex: 6,
                  child: Column(
                    children: [
                      // SEARCH & CATEGORY DROPDOWN BAR
                      Row(
                        children: [
                          // SEARCH BAR
                          Expanded(
                            flex: 3,
                            child: Container(
                              height: 42,
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: theme.dividerColor.withValues(alpha: 0.6),
                                ),
                              ),
                              child: TextField(
                                onChanged: controller.onSearchChanged,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colors.onSurface,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search menu items...',
                                  hintStyle: TextStyle(
                                    fontSize: 13,
                                    color: colors.onSurfaceVariant,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    size: 18,
                                    color: colors.onSurfaceVariant,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 11,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          // CATEGORY DROPDOWN
                          Obx(() {
                            return Container(
                              height: 42,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: theme.dividerColor.withValues(alpha: 0.6),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: controller.selectedCategory.value,
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 18,
                                    color: colors.onSurfaceVariant,
                                  ),
                                  items: [
                                    const DropdownMenuItem(
                                      value: 'all',
                                      child: Text(
                                        'All Categories',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ),
                                    ...controller.categories.map((c) {
                                      return DropdownMenuItem(
                                        value: c.id,
                                        child: Text(
                                          c.name,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      );
                                    }),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      controller.selectCategoryFilter(val);
                                    }
                                  },
                                ),
                              ),
                            );
                          }),

                          const SizedBox(width: 10),

                          // FILTER ICON BUTTON
                          Container(
                            height: 42,
                            width: 42,
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: theme.dividerColor.withValues(alpha: 0.6),
                              ),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.tune,
                                size: 18,
                                color: colors.onSurfaceVariant,
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // CATEGORY COUNT PILLS (HORIZONTAL LIST)
                      Obx(() {
                        return SizedBox(
                          height: 34,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _buildCategoryPill(
                                context,
                                'All',
                                'all',
                                controller.getCategoryCount('all'),
                                controller.selectedCategory.value == 'all',
                                () => controller.selectCategoryFilter('all'),
                              ),
                              ...controller.categories.map((c) {
                                final isSelected =
                                    controller.selectedCategory.value == c.id;
                                final count = controller.getCategoryCount(c.id);
                                return _buildCategoryPill(
                                  context,
                                  c.name,
                                  c.id,
                                  count,
                                  isSelected,
                                  () => controller.selectCategoryFilter(c.id),
                                );
                              }),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 14),

                      // PRODUCTS LIST
                      Expanded(
                        child: Obx(() {
                          if (controller.isLoading.value) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            );
                          }

                          final items = controller.filteredProducts;

                          if (items.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.restaurant_menu,
                                    size: 48,
                                    color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'No menu items found',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.separated(
                            itemCount: items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final product = items[index];
                              final isSelected = !controller.isCreatingNew.value &&
                                  controller.selectedProduct.value?.id == product.id;

                              return _buildProductRowTile(
                                context,
                                product,
                                isSelected,
                                controller,
                              );
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 20),

                // ======================================================
                // RIGHT PANEL: Product Details / Editor Form Card
                // ======================================================
                Expanded(
                  flex: 4,
                  child: Obx(() {
                    return _buildProductEditorCard(context, controller);
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // CATEGORY PILL COMPONENT
  // ===========================================================================
  Widget _buildCategoryPill(
    BuildContext context,
    String name,
    String id,
    int count,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : (isDark ? const Color(0xFF1E2636) : const Color(0xFFF1F3F5)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : theme.dividerColor.withValues(alpha: 0.5),
            ),
          ),
          child: Text(
            '$name ($count)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? Colors.white : colors.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // PRODUCT ROW TILE (LEFT LIST)
  // ===========================================================================
  Widget _buildProductRowTile(
    BuildContext context,
    ProductModel product,
    bool isSelected,
    MenuManagementController controller,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () => controller.selectProduct(product),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : theme.dividerColor.withValues(alpha: 0.6),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // PRODUCT THUMBNAIL
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF222B3B) : const Color(0xFFFAF5EE),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SvgPicture.asset(
                  product.image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.fastfood,
                    size: 24,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // NAME & CATEGORY
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.category.name.capitalizeFirst ?? 'General',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // PRICE
            Text(
              'Rs ${product.price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(width: 14),

            // STATUS BADGE (Available / Unavailable)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: product.isActive
                    ? (isDark
                        ? const Color(0xFF1E3A2F)
                        : const Color(0xFFE8F5E9))
                    : (isDark
                        ? const Color(0xFF3E1E24)
                        : const Color(0xFFFFEBEE)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                product.isActive ? 'Available' : 'Unavailable',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: product.isActive
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFC62828),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // EDIT BUTTON
            OutlinedButton.icon(
              onPressed: () => controller.selectProduct(product),
              icon: const Icon(Icons.edit_outlined, size: 14),
              label: const Text('Edit', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.onSurface,
                side: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.7),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: const Size(0, 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),

            const SizedBox(width: 4),

            // THREE DOTS ACTION MENU
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, size: 18, color: colors.onSurfaceVariant),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              onSelected: (action) {
                if (action == 'toggle') {
                  controller.toggleProductAvailability(product);
                } else if (action == 'delete') {
                  _showDeleteConfirmDialog(context, product, controller);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        product.isActive
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(product.isActive
                          ? 'Mark Unavailable'
                          : 'Mark Available'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete Item', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // RIGHT EDITOR CARD (FORM)
  // ===========================================================================
  Widget _buildProductEditorCard(
    BuildContext context,
    MenuManagementController controller,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isNew = controller.isCreatingNew.value;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER ROW: Product Details + Delete Item Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextWidget(
                    isNew ? 'New Product' : 'Product Details',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  CustomTextWidget(
                    isNew
                        ? 'Fill details to add item to the menu.'
                        : 'Update the information for this menu item.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (!isNew && controller.selectedProduct.value != null)
                OutlinedButton.icon(
                  onPressed: () => _showDeleteConfirmDialog(
                    context,
                    controller.selectedProduct.value!,
                    controller,
                  ),
                  icon: const Icon(Icons.delete_outline, size: 14, color: Colors.red),
                  label: const Text(
                    'Delete Item',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Colors.red.withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    minimumSize: const Size(0, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.4)),
          const SizedBox(height: 16),

          // SCROLLABLE FORM FIELDS
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // IMAGE PREVIEW & BASIC INFO ROW
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // PRODUCT IMAGE BOX
                      SizedBox(
                        width: 140,
                        child: Column(
                          children: [
                            Container(
                              width: 140,
                              height: 120,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF222B3B)
                                    : const Color(0xFFFAF5EE),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.dividerColor.withValues(alpha: 0.6),
                                ),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: SvgPicture.asset(
                                controller.formImage.value,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.fastfood,
                                  size: 44,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: () => _showSelectImageModal(context, controller),
                              icon: const Icon(Icons.upload_outlined, size: 13),
                              label: const Text(
                                'Change Image',
                                style: TextStyle(fontSize: 11),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colors.onSurface,
                                side: BorderSide(
                                  color: theme.dividerColor.withValues(alpha: 0.7),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                minimumSize: const Size(double.infinity, 30),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      // PRODUCT NAME, CATEGORY, PRICE
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // NAME
                            _buildInputLabel(context, 'Product Name *'),
                            const SizedBox(height: 4),
                            _buildTextField(
                              controller.nameController,
                              'e.g. Classic Smash Burger',
                              context,
                            ),

                            const SizedBox(height: 12),

                            // CATEGORY
                            _buildInputLabel(context, 'Category *'),
                            const SizedBox(height: 4),
                            Container(
                              height: 38,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainer,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: theme.dividerColor.withValues(alpha: 0.6),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: controller.formCategory.value,
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 18,
                                    color: colors.onSurfaceVariant,
                                  ),
                                  items: controller.categories.map((c) {
                                    return DropdownMenuItem(
                                      value: c.id,
                                      child: Text(
                                        c.name,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      controller.onCategoryFormChanged(val);
                                    }
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // PRICE
                            _buildInputLabel(context, 'Price (Rs) *'),
                            const SizedBox(height: 4),
                            _buildTextField(
                              controller.priceController,
                              'e.g. 620',
                              context,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // DESCRIPTION
                  _buildInputLabel(context, 'Description'),
                  const SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: colors.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.6),
                      ),
                    ),
                    child: TextField(
                      controller: controller.descriptionController,
                      maxLines: 3,
                      maxLength: 200,
                      style: TextStyle(fontSize: 13, color: colors.onSurface),
                      decoration: InputDecoration(
                        hintText:
                            'Juicy smashed beef patty with fresh lettuce, tomato, cheese and our special sauce.',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // SIZE OPTIONS SECTION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInputLabel(context, 'Size Options'),
                      InkWell(
                        onTap: () => _showAddSizeModal(context, controller),
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Text(
                            '+ Add Size',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // SIZE OPTIONS CHIPS / MINI LIST
                  Obx(() {
                    if (controller.currentSizes.isEmpty) {
                      return Text(
                        'No custom sizes defined. Default standard sizes will be used.',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                        ),
                      );
                    }

                    return Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: controller.currentSizes.map((size) {
                        final extraText = size.extraPrice > 0
                            ? ' (+ Rs ${size.extraPrice.toStringAsFixed(0)})'
                            : ' (Rs 0)';
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainer,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: theme.dividerColor.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${size.name}$extraText',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: colors.onSurface,
                                ),
                              ),
                              const SizedBox(width: 4),
                              InkWell(
                                onTap: () => controller.removeSizeOption(size.id),
                                child: Icon(
                                  Icons.close,
                                  size: 13,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  }),

                  const SizedBox(height: 16),

                  // ADD-ONS / EXTRAS SECTION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInputLabel(context, 'Add-ons & Extras'),
                      InkWell(
                        onTap: () => _showAddAddonModal(context, controller),
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Text(
                            '+ Add Extra',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // ADD-ONS CHIPS / MINI LIST
                  Obx(() {
                    if (controller.currentAddons.isEmpty) {
                      return Text(
                        'No extras defined for this category yet. Tap + Add Extra.',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                        ),
                      );
                    }

                    return Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: controller.currentAddons.map((addon) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainer,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: theme.dividerColor.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${addon.name} (+ Rs ${addon.price.toStringAsFixed(0)})',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: colors.onSurface,
                                ),
                              ),
                              const SizedBox(width: 4),
                              InkWell(
                                onTap: () => controller.removeAddon(addon.id),
                                child: Icon(
                                  Icons.close,
                                  size: 13,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  }),

                  const SizedBox(height: 18),

                  // AVAILABLE FOR ORDER TOGGLE
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainer,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Available for Order',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: colors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'When disabled, this item will not appear in the POS.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: controller.formIsAvailable.value,
                          activeThumbColor: AppColors.primary,
                          onChanged: (val) =>
                              controller.formIsAvailable.value = val,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // BOTTOM ACTION BUTTONS
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () {
                  if (controller.products.isNotEmpty) {
                    controller.selectProduct(controller.products.first);
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.onSurface,
                  side: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.6),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Cancel', style: TextStyle(fontSize: 13)),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: controller.isSaving.value
                    ? null
                    : () => controller.saveProduct(),
                icon: controller.isSaving.value
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined, size: 16, color: Colors.white),
                label: Text(
                  isNew ? 'Create Item' : 'Save Changes',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(BuildContext context, String label) {
    final colors = Theme.of(context).colorScheme;
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: colors.onSurface,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController textController,
    String hint,
    BuildContext context, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.6),
        ),
      ),
      child: TextField(
        controller: textController,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 13, color: colors.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 12,
            color: colors.onSurfaceVariant,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    ProductModel product,
    MenuManagementController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Menu Item?'),
        content: Text(
          'Are you sure you want to delete "${product.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteProduct(product.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddAddonModal(
    BuildContext context,
    MenuManagementController controller,
  ) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add New Extra / Add-on'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Add-on Name (e.g. Extra dip)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price in Rs (e.g. 50)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
              if (name.isNotEmpty) {
                Get.back();
                controller.addNewAddon(name, price);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Add Add-on', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddSizeModal(
    BuildContext context,
    MenuManagementController controller,
  ) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add New Size Option'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Size Name (e.g. Large, Jumbo, XL)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Extra Price in Rs (e.g. 120, 0 for regular)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final extraPrice = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
              if (name.isNotEmpty) {
                Get.back();
                controller.addNewSizeOption(name, extraPrice);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Add Size', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSelectImageModal(
    BuildContext context,
    MenuManagementController controller,
  ) {
    final images = [
      'assets/svg/products/burger.svg',
      'assets/svg/products/pizza.svg',
      'assets/svg/products/chicken.svg',
      'assets/svg/products/fries.svg',
      'assets/svg/products/drink.svg',
      'assets/svg/products/dessert.svg',
    ];

    Get.dialog(
      AlertDialog(
        title: const Text('Choose Product Graphic'),
        content: SizedBox(
          width: 320,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: images.map((img) {
              return InkWell(
                onTap: () {
                  controller.formImage.value = img;
                  Get.back();
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 80,
                  height: 80,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: controller.formImage.value == img
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: controller.formImage.value == img
                          ? AppColors.primary
                          : Colors.grey.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: SvgPicture.asset(img),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
