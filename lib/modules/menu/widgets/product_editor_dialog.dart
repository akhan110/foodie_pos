import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/app/widgets/app_image_widget.dart';
import 'package:foodiepos/app/widgets/custom_text_widget.dart';
import 'package:foodiepos/modules/menu/controllers/menu_management_controller.dart';
import 'package:foodiepos/modules/pos/model/product_category.dart';
import 'package:foodiepos/modules/pos/model/product_model.dart';
import 'package:get/get.dart';

class ProductEditorDialog extends StatelessWidget {
  const ProductEditorDialog({super.key, required this.controller});

  final MenuManagementController controller;

  static Future<void> show(
    BuildContext context, {
    ProductModel? product,
    bool isNew = false,
  }) async {
    final ctrl = Get.isRegistered<MenuManagementController>()
        ? Get.find<MenuManagementController>()
        : Get.put(MenuManagementController());
    if (ctrl.categories.isEmpty) {
      await ctrl.loadMenu();
    }
    if (isNew || product == null) {
      ctrl.startNewProduct();
    } else {
      ctrl.selectProduct(product);
    }

    if (!context.mounted) return;

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880, maxHeight: 720),
          child: ProductEditorDialog(controller: ctrl),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final isNew = controller.isCreatingNew.value;

      return Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E222B) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? const Color(0xFF2D333F) : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
              blurRadius: 36,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================================
            // 1. TOP HEADER: Title & Actions (Cancel, Save Product)
            // ============================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextWidget(
                      isNew ? 'Add / Create Product' : 'Add / Edit Product',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    CustomTextWidget(
                      'Create a menu item and its modifiers',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.onSurface,
                        side: BorderSide(
                          color: isDark
                              ? const Color(0xFF374151)
                              : const Color(0xFFD1D5DB),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: controller.isSaving.value
                          ? null
                          : () async {
                              await controller.saveProduct();
                              Get.back();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: controller.isSaving.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save Product',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ============================================================
            // 2. MAIN 2-COLUMN BODY
            // ============================================================
            Expanded(
              child: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LEFT COLUMN: Product Image
                    SizedBox(
                      width: 320,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextWidget(
                            'Product Image',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // PREVIEW CARD
                          Container(
                            width: double.infinity,
                            height: 210,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF141822)
                                  : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF2D333F)
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // INNER FOOD CONTAINER
                                Container(
                                  width: 160,
                                  height: 130,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1E222B)
                                        : const Color(0xFFFAF5EE),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.all(14),
                                  child: AppImageWidget(
                                    imagePath: controller.formImage.value,
                                    fit: BoxFit.contain,
                                    borderRadius: BorderRadius.circular(12),
                                    fallbackIconSize: 48,
                                  ),
                                ),
                                if (controller.isUploadingImage.value)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.55),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // CHANGE IMAGE BUTTON
                          OutlinedButton(
                            onPressed: () => _showChangeImageOptions(context, controller),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colors.onSurface,
                              side: BorderSide(
                                color: isDark
                                    ? const Color(0xFF374151)
                                    : const Color(0xFFD1D5DB),
                              ),
                              minimumSize: const Size(double.infinity, 44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Change image',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 28),

                    // RIGHT COLUMN: Basic Information, Availability & Modifier Groups
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextWidget(
                            'Basic Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // ROW 1: PRODUCT NAME & SKU
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: _buildLabeledInput(
                                  context: context,
                                  label: 'PRODUCT NAME',
                                  controller: controller.nameController,
                                  hint: 'Classic Smash Burger',
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                flex: 2,
                                child: _buildLabeledInput(
                                  context: context,
                                  label: 'SKU',
                                  controller: controller.skuController,
                                  hint: 'BRG-001',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // ROW 2: CATEGORY & BASE PRICE
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel(context, 'CATEGORY'),
                                    const SizedBox(height: 6),
                                    Builder(
                                      builder: (context) {
                                        // Fallback default categories if not yet fetched
                                        final catList = controller.categories.isNotEmpty
                                            ? controller.categories.toList()
                                            : [
                                                ProductCategoryModel(id: 'burgers', name: 'Burgers', slug: 'burgers'),
                                                ProductCategoryModel(id: 'chicken', name: 'Chicken', slug: 'chicken'),
                                                ProductCategoryModel(id: 'pizza', name: 'Pizza', slug: 'pizza'),
                                                ProductCategoryModel(id: 'sides', name: 'Sides', slug: 'sides'),
                                                ProductCategoryModel(id: 'drinks', name: 'Drinks', slug: 'drinks'),
                                                ProductCategoryModel(id: 'desserts', name: 'Desserts', slug: 'desserts'),
                                              ];

                                        final currentVal = controller.formCategory.value;
                                        final matchedCat = catList.firstWhereOrNull(
                                          (c) => c.id.toLowerCase() == currentVal.toLowerCase() ||
                                                 c.name.toLowerCase() == currentVal.toLowerCase() ||
                                                 c.slug.toLowerCase() == currentVal.toLowerCase(),
                                        );
                                        final safeValue = matchedCat?.id ?? catList.first.id;

                                        return Container(
                                          height: 44,
                                          padding: const EdgeInsets.symmetric(horizontal: 14),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? const Color(0xFF141822)
                                                : const Color(0xFFF3F4F6),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: isDark
                                                  ? const Color(0xFF2D333F)
                                                  : const Color(0xFFE5E7EB),
                                            ),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: safeValue,
                                              isExpanded: true,
                                              icon: const Icon(
                                                Icons.keyboard_arrow_down_rounded,
                                                size: 20,
                                                color: AppColors.primary,
                                              ),
                                              dropdownColor: isDark
                                                  ? const Color(0xFF1E222B)
                                                  : Colors.white,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: colors.onSurface,
                                              ),
                                              onChanged: (val) {
                                                if (val != null) {
                                                  controller.onCategoryFormChanged(val);
                                                }
                                              },
                                              items: catList.map((c) {
                                                return DropdownMenuItem<String>(
                                                  value: c.id,
                                                  child: Text(
                                                    c.name,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w600,
                                                      color: colors.onSurface,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                flex: 2,
                                child: _buildLabeledInput(
                                  context: context,
                                  label: 'BASE PRICE',
                                  controller: controller.priceController,
                                  hint: 'Rs 620',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                flex: 2,
                                child: _buildLabeledInput(
                                  context: context,
                                  label: 'COOK TIME (MINS)',
                                  controller: controller.prepTimeController,
                                  hint: '3',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // ROW 3: DESCRIPTION
                          _buildLabeledInput(
                            context: context,
                            label: 'DESCRIPTION',
                            controller: controller.descriptionController,
                            hint: 'Double-seared beef, cheese, lettuce and BiteFlow sauce.',
                            maxLines: 2,
                          ),

                          const SizedBox(height: 16),

                          // AVAILABILITY SECTION
                          _buildFieldLabel(context, 'AVAILABILITY'),
                          const SizedBox(height: 8),

                          // Available for sale toggle
                          _buildToggleTile(
                            context: context,
                            title: 'Available for sale',
                            subtitle: 'Show this item on the POS',
                            value: controller.formIsAvailable.value,
                            onChanged: (val) => controller.formIsAvailable.value = val,
                          ),
                          const SizedBox(height: 6),

                          // Kitchen preparation toggle
                          _buildToggleTile(
                            context: context,
                            title: 'Kitchen preparation',
                            subtitle: 'Send item to kitchen display',
                            value: controller.formIsKitchen.value,
                            onChanged: (val) => controller.formIsKitchen.value = val,
                          ),

                          const SizedBox(height: 16),

                          // MODIFIER GROUPS SECTION
                          _buildFieldLabel(context, 'MODIFIER GROUPS'),
                          const SizedBox(height: 8),

                          // Sizes Card
                          _buildModifierGroupTile(
                            context: context,
                            title: 'Sizes',
                            detail: controller.currentSizes.isEmpty
                                ? 'Regular (Default)'
                                : controller.currentSizes.map((s) => s.name).join(', '),
                            onManage: () => _showManageSizesDialog(context, controller),
                          ),

                          const SizedBox(height: 6),

                          // Extras Card
                          _buildModifierGroupTile(
                            context: context,
                            title: 'Extras',
                            detail: controller.currentAddons.isEmpty
                                ? 'None defined'
                                : controller.currentAddons.map((a) => a.name).join(', '),
                            onManage: () => _showManageAddonsDialog(context, controller),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFieldLabel(BuildContext context, String text) {
    final colors = Theme.of(context).colorScheme;
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: colors.onSurfaceVariant,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildLabeledInput({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(context, label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 13,
              color: colors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF141822) : const Color(0xFFF3F4F6),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF2D333F) : const Color(0xFFE5E7EB),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF2D333F) : const Color(0xFFE5E7EB),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141822) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF2D333F) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextWidget(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 1),
              CustomTextWidget(
                subtitle,
                style: TextStyle(
                  fontSize: 11.5,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Switch(
            value: value,
            activeThumbColor: const Color(0xFF10B981),
            activeTrackColor: const Color(0xFF10B981).withValues(alpha: 0.35),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildModifierGroupTile({
    required BuildContext context,
    required String title,
    required String detail,
    required VoidCallback onManage,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141822) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF2D333F) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$title · ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                  TextSpan(
                    text: detail,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: onManage,
            borderRadius: BorderRadius.circular(6),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Text(
                'Manage →',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangeImageOptions(
    BuildContext context,
    MenuManagementController controller,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.cloud_upload_outlined, color: AppColors.primary),
              title: const Text('Upload Photo from Computer'),
              subtitle: const Text('JPG, PNG, WebP or SVG'),
              onTap: () {
                Get.back();
                controller.pickAndUploadRealImage();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.grid_view_rounded, color: AppColors.primary),
              title: const Text('Choose Preset Graphic'),
              subtitle: const Text('Fast food icons and vector illustrations'),
              onTap: () {
                Get.back();
                _showSelectPresetModal(context, controller);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSelectPresetModal(
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
        title: const Text('Select Preset Graphic'),
        content: SizedBox(
          width: 340,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: images.map((img) {
              return InkWell(
                onTap: () {
                  controller.formImage.value = img;
                  Get.back();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 90,
                  height: 90,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: controller.formImage.value == img
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : Colors.grey.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: controller.formImage.value == img
                          ? AppColors.primary
                          : Colors.grey.withValues(alpha: 0.25),
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

  void _showManageSizesDialog(
    BuildContext context,
    MenuManagementController controller,
  ) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Manage Sizes'),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() {
                if (controller.currentSizes.isEmpty) {
                  return const Text('No custom sizes. Regular size applies.');
                }
                return Column(
                  children: controller.currentSizes.map((size) {
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        size.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text('+ Rs ${size.extraPrice.toStringAsFixed(0)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () => controller.removeSizeOption(size.id),
                      ),
                    );
                  }).toList(),
                );
              }),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Size Name (e.g. XL)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Extra (Rs)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final extra = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
                  if (name.isNotEmpty) {
                    controller.addNewSizeOption(name, extra);
                    nameCtrl.clear();
                    priceCtrl.clear();
                  }
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Size Option'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showManageAddonsDialog(
    BuildContext context,
    MenuManagementController controller,
  ) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Manage Extras & Add-ons'),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() {
                if (controller.currentAddons.isEmpty) {
                  return const Text('No extras defined for this category.');
                }
                return Column(
                  children: controller.currentAddons.map((addon) {
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        addon.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text('+ Rs ${addon.price.toStringAsFixed(0)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () => controller.removeAddon(addon.id),
                      ),
                    );
                  }).toList(),
                );
              }),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Add-on (e.g. Cheese)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Price (Rs)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
                  if (name.isNotEmpty) {
                    controller.addNewAddon(name, price);
                    nameCtrl.clear();
                    priceCtrl.clear();
                  }
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Extra'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
