import 'package:flutter/material.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/app/widgets/app_image_widget.dart';
import 'package:foodiepos/app/widgets/custom_text_widget.dart';
import 'package:foodiepos/modules/menu/controllers/menu_management_controller.dart';
import 'package:foodiepos/modules/menu/widgets/product_editor_dialog.dart';
import 'package:foodiepos/modules/pos/model/product_category.dart';
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
      child: Obx(() {
        final currentTab = controller.selectedTab.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================================
            // 1. TOP HEADER & TAB SWITCHER
            // ============================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextWidget(
                      currentTab == 0 ? 'Menu Management' : 'Categories & Add-ons',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        color: colors.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    CustomTextWidget(
                      currentTab == 0
                          ? 'Add, edit and organize your menu items, real photos, prices and sizes.'
                          : 'Organize your menu and optional extras',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    // TAB SWITCHER PILLS
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E222B) : const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          _buildTabButton(
                            title: 'Products',
                            isSelected: currentTab == 0,
                            onTap: () => controller.selectedTab.value = 0,
                            isDark: isDark,
                            colors: colors,
                          ),
                          _buildTabButton(
                            title: 'Categories & Add-ons',
                            isSelected: currentTab == 1,
                            onTap: () => controller.selectedTab.value = 1,
                            isDark: isDark,
                            colors: colors,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    // TOP ACTION BUTTON
                    if (currentTab == 0)
                      ElevatedButton.icon(
                        onPressed: () => ProductEditorDialog.show(context, isNew: true),
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
              ],
            ),

            const SizedBox(height: 18),

            // ============================================================
            // 2. TAB CONTENT
            // ============================================================
            Expanded(
              child: currentTab == 0
                  ? _buildProductsTabView(context, controller, theme, colors, isDark)
                  : _buildCategoriesAndAddonsTabView(context, controller, theme, colors, isDark),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required ColorScheme colors,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF2D333F) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? AppColors.primary : colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PRODUCTS TAB VIEW
  // ============================================================
  Widget _buildProductsTabView(
    BuildContext context,
    MenuManagementController controller,
    ThemeData theme,
    ColorScheme colors,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SEARCH & CATEGORY DROPDOWN BAR
        Row(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
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
                    hintText: 'Search menu items by name...',
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
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Obx(() {
              return Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
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
                    dropdownColor: isDark ? const Color(0xFF1E222B) : Colors.white,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                    onChanged: (val) {
                      if (val != null) {
                        controller.selectCategoryFilter(val);
                      }
                    },
                    items: [
                      const DropdownMenuItem(
                        value: 'all',
                        child: Text('All Categories'),
                      ),
                      ...controller.categories.map((c) {
                        return DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        );
                      }),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),

        const SizedBox(height: 14),

        // HORIZONTAL CATEGORY FILTER PILLS
        Obx(() {
          return SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryFilterPill(
                  context: context,
                  label: 'All (${controller.getCategoryCount('all')})',
                  categoryId: 'all',
                  isSelected: controller.selectedCategory.value == 'all',
                  onTap: () => controller.selectCategoryFilter('all'),
                ),
                const SizedBox(width: 8),
                ...controller.categories.map((cat) {
                  final isSelected = controller.selectedCategory.value == cat.id;
                  final count = controller.getCategoryCount(cat.id);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildCategoryFilterPill(
                      context: context,
                      label: '${cat.name} ($count)',
                      categoryId: cat.id,
                      isSelected: isSelected,
                      onTap: () => controller.selectCategoryFilter(cat.id),
                    ),
                  );
                }),
              ],
            ),
          );
        }),

        const SizedBox(height: 14),

        // FULL-WIDTH PRODUCTS LIST
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            final list = controller.filteredProducts;

            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fastfood_outlined,
                      size: 48,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    CustomTextWidget(
                      'No menu items found.',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    CustomTextWidget(
                      'Tap "+ Add New Item" to create your first product.',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              itemCount: list.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final product = list[index];
                return _buildProductRow(context, product, controller);
              },
            );
          }),
        ),
      ],
    );
  }

  // ============================================================
  // CATEGORIES & ADD-ONS TAB VIEW (SCREENSHOT 1)
  // ============================================================
  Widget _buildCategoriesAndAddonsTabView(
    BuildContext context,
    MenuManagementController controller,
    ThemeData theme,
    ColorScheme colors,
    bool isDark,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ============================================================
        // LEFT CARD: Categories
        // ============================================================
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E222B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF2D333F) : const Color(0xFFE5E7EB),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CARD HEADER: Categories + "+ Add Category"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomTextWidget(
                      'Categories',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddCategoryDialog(context, controller),
                      icon: const Icon(Icons.add, size: 16, color: Colors.white),
                      label: const Text(
                        '+ Add Category',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // CATEGORIES LIST
                Expanded(
                  child: Obx(() {
                    if (controller.categories.isEmpty) {
                      return Center(
                        child: Text(
                          'No categories found.',
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: controller.categories.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: isDark ? const Color(0xFF2D333F) : const Color(0xFFF0F2F5),
                      ),
                      itemBuilder: (context, index) {
                        final cat = controller.categories[index];
                        final count = controller.getCategoryCount(cat.id);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // CATEGORY NAME & PRODUCT COUNT
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextWidget(
                                    cat.name,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  CustomTextWidget(
                                    '$count products',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),

                              // ACTION ICONS: Reorder, Edit, More
                              Row(
                                children: [
                                  Icon(
                                    Icons.unfold_more_rounded,
                                    size: 18,
                                    color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                                  ),
                                  const SizedBox(width: 14),
                                  InkWell(
                                    onTap: () => _showEditCategoryDialog(context, controller, cat),
                                    child: Icon(
                                      Icons.edit_outlined,
                                      size: 17,
                                      color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  PopupMenuButton<String>(
                                    icon: Icon(
                                      Icons.more_horiz,
                                      size: 20,
                                      color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                                    ),
                                    onSelected: (val) {
                                      if (val == 'edit') {
                                        _showEditCategoryDialog(context, controller, cat);
                                      } else if (val == 'delete') {
                                        _showDeleteCategoryConfirm(context, controller, cat);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit_outlined, size: 16),
                                            SizedBox(width: 8),
                                            Text('Edit Category'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Delete Category', style: TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 24),

        // ============================================================
        // RIGHT CARD: Add-ons
        // ============================================================
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E222B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF2D333F) : const Color(0xFFE5E7EB),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CARD HEADER: Add-ons + "+ Add Add-on"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomTextWidget(
                      'Add-ons',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddAddonDialog(context, controller),
                      icon: const Icon(Icons.add, size: 16, color: Colors.white),
                      label: const Text(
                        '+ Add Add-on',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ADD-ONS LIST
                Expanded(
                  child: Obx(() {
                    if (controller.allAddons.isEmpty) {
                      return Center(
                        child: Text(
                          'No add-ons found. Tap "+ Add Add-on" to create one.',
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: controller.allAddons.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: isDark ? const Color(0xFF2D333F) : const Color(0xFFF0F2F5),
                      ),
                      itemBuilder: (context, index) {
                        final addon = controller.allAddons[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // ADDON NAME & SUBTITLE
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextWidget(
                                    addon.name,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  CustomTextWidget(
                                    'Optional modifier',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),

                              // PRICE & ACTIVE SWITCH
                              Row(
                                children: [
                                  CustomTextWidget(
                                    'Rs ${addon.price.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Switch(
                                    value: addon.isActive,
                                    activeThumbColor: const Color(0xFF10B981),
                                    activeTrackColor:
                                        const Color(0xFF10B981).withValues(alpha: 0.35),
                                    onChanged: (val) => controller.toggleAddon(addon),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DIALOG HELPERS
  // ============================================================
  void _showAddCategoryDialog(
    BuildContext context,
    MenuManagementController controller,
  ) {
    final nameCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add New Category'),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Category Name (e.g. Combos, Burgers)',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isNotEmpty) {
                Get.back();
                controller.createCategory(name);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Add Category', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(
    BuildContext context,
    MenuManagementController controller,
    ProductCategoryModel category,
  ) {
    final nameCtrl = TextEditingController(text: category.name);

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Category'),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Category Name'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isNotEmpty) {
                Get.back();
                controller.updateCategory(category.id, name);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteCategoryConfirm(
    BuildContext context,
    MenuManagementController controller,
    ProductCategoryModel category,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Category?'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteCategory(category.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddAddonDialog(
    BuildContext context,
    MenuManagementController controller,
  ) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add New Add-on'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Modifier Name (e.g. Extra patty)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price in Rs (e.g. 90)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
              if (name.isNotEmpty) {
                Get.back();
                controller.createAddonGlobal(name, price);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Add Add-on', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilterPill({
    required BuildContext context,
    required String label,
    required String categoryId,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? const Color(0xFF1E222B) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? const Color(0xFF2D333F) : theme.dividerColor),
          ),
        ),
        child: CustomTextWidget(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : colors.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildProductRow(
    BuildContext context,
    ProductModel product,
    MenuManagementController controller,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () => ProductEditorDialog.show(context, product: product),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E222B) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF2D333F) : theme.dividerColor,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // PRODUCT THUMBNAIL
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF252A36) : const Color(0xFFFAF5EE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.5),
                ),
              ),
              padding: const EdgeInsets.all(6),
              child: AppImageWidget(
                imagePath: product.image,
                fit: BoxFit.contain,
                borderRadius: BorderRadius.circular(8),
                fallbackIconSize: 24,
              ),
            ),

            const SizedBox(width: 16),

            // PRODUCT NAME & CATEGORY & DESCRIPTION
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: CustomTextWidget(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                      if (product.isPopular) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'POPULAR',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  CustomTextWidget(
                    '${product.category.name.capitalizeFirst ?? product.category.name} · SKU: ${product.sku ?? product.effectiveSku}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 20),

            // PRICE
            CustomTextWidget(
              'Rs ${product.price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(width: 16),

            // AVAILABILITY BADGE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: product.isActive
                    ? AppColors.successSurface
                    : AppColors.errorSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomTextWidget(
                product.isActive ? 'Available' : 'Unavailable',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: product.isActive ? AppColors.success : AppColors.error,
                ),
              ),
            ),

            const SizedBox(width: 14),

            // EDIT BUTTON
            ElevatedButton.icon(
              onPressed: () => ProductEditorDialog.show(context, product: product),
              icon: const Icon(Icons.edit_outlined, size: 14, color: Colors.white),
              label: const Text('Edit', style: TextStyle(fontSize: 12, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            ),

            const SizedBox(width: 6),

            // THREE DOTS ACTION MENU
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, size: 18, color: colors.onSurfaceVariant),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              onSelected: (action) {
                if (action == 'toggle') {
                  controller.toggleProductAvailability(product);
                } else if (action == 'delete') {
                  _showDeleteProductConfirm(context, product, controller);
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
                      Text(product.isActive ? 'Mark Unavailable' : 'Mark Available'),
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

  void _showDeleteProductConfirm(
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
}
