import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/app/widgets/app_image_widget.dart';
import 'package:foodiepos/app/widgets/custom_text_widget.dart';
import 'package:foodiepos/modules/menu/controllers/menu_management_controller.dart';
import 'package:foodiepos/modules/pos/model/product_model.dart';
import 'package:get/get.dart';

class ProductEditorDialog extends StatelessWidget {
  const ProductEditorDialog({super.key, required this.controller});

  final MenuManagementController controller;

  static Future<void> show(
    BuildContext context, {
    ProductModel? product,
    bool isNew = false,
  }) {
    final ctrl = Get.find<MenuManagementController>();
    if (isNew || product == null) {
      ctrl.startNewProduct();
    } else {
      ctrl.selectProduct(product);
    }

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 620,
            maxHeight: 760,
          ),
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
      final selectedProd = controller.selectedProduct.value;

      return Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E222B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF2D333F) : theme.dividerColor,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isNew ? Icons.add_circle_outline : Icons.edit_note_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextWidget(
                          isNew ? 'Create Menu Item' : 'Edit Product',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: colors.onSurface,
                          ),
                        ),
                        CustomTextWidget(
                          isNew
                              ? 'Fill details and upload a photo to add to POS'
                              : 'Update details, prices, sizes, or photo',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => Get.back(),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF252A36) : const Color(0xFFF1F3F7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 16, color: colors.onSurfaceVariant),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.4)),
            const SizedBox(height: 14),

            // FORM BODY (Scrollable)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TOP ROW: IMAGE PICKER & BASIC INFO
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // PHOTO UPLOAD BOX
                        SizedBox(
                          width: 150,
                          child: Column(
                            children: [
                              Container(
                                width: 150,
                                height: 130,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF252A36) : const Color(0xFFFAF5EE),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: theme.dividerColor.withValues(alpha: 0.6),
                                  ),
                                ),
                                padding: const EdgeInsets.all(10),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    AppImageWidget(
                                      imagePath: controller.formImage.value,
                                      fit: BoxFit.contain,
                                      borderRadius: BorderRadius.circular(10),
                                      fallbackIconSize: 42,
                                    ),
                                    if (controller.isUploadingImage.value)
                                      Container(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),

                              // UPLOAD REAL IMAGE BUTTON
                              ElevatedButton.icon(
                                onPressed: controller.isUploadingImage.value
                                    ? null
                                    : () => controller.pickAndUploadRealImage(),
                                icon: const Icon(Icons.cloud_upload_outlined, size: 14, color: Colors.white),
                                label: const Text(
                                  'Upload Photo',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  minimumSize: const Size(double.infinity, 32),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),

                              // CHOOSE GRAPHIC / ICON
                              OutlinedButton.icon(
                                onPressed: () => _showSelectImageModal(context, controller),
                                icon: const Icon(Icons.grid_view_rounded, size: 13),
                                label: const Text(
                                  'Preset Icon',
                                  style: TextStyle(fontSize: 11),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colors.onSurface,
                                  side: BorderSide(
                                    color: theme.dividerColor.withValues(alpha: 0.6),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  minimumSize: const Size(double.infinity, 28),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 16),

                        // NAME, CATEGORY & BASE PRICE
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(context, 'Product Name *'),
                              const SizedBox(height: 4),
                              _buildTextField(
                                controller.nameController,
                                'e.g. Classic Smash Burger',
                                context,
                              ),

                              const SizedBox(height: 10),

                              _buildLabel(context, 'Category *'),
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
                                    value: controller.formCategory.value,
                                    isExpanded: true,
                                    dropdownColor: isDark ? const Color(0xFF1E222B) : Colors.white,
                                    onChanged: (val) {
                                      if (val != null) {
                                        controller.onCategoryFormChanged(val);
                                      }
                                    },
                                    items: controller.categories.map((c) {
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
                              ),

                              const SizedBox(height: 10),

                              _buildLabel(context, 'Base Price (Rs) *'),
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

                    const SizedBox(height: 14),

                    // DESCRIPTION
                    _buildLabel(context, 'Description'),
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
                        maxLines: 2,
                        maxLength: 180,
                        style: TextStyle(fontSize: 12, color: colors.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Juicy smashed beef patty with special sauce...',
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // SIZE OPTIONS SECTION
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel(context, 'Size Options (Tiers)'),
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

                    // SIZES LIST
                    Obx(() {
                      if (controller.currentSizes.isEmpty) {
                        return Text(
                          'No custom sizes defined. Regular size applies.',
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

                    const SizedBox(height: 14),

                    // ADD-ONS & EXTRAS SECTION
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel(context, 'Add-ons & Extras'),
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

                    // ADD-ONS LIST
                    Obx(() {
                      if (controller.currentAddons.isEmpty) {
                        return Text(
                          'No extras defined. Tap + Add Extra.',
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

                    const SizedBox(height: 14),

                    // AVAILABILITY TOGGLE
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Available for Ordering',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: colors.onSurface,
                                ),
                              ),
                              Text(
                                'Display this product on POS counters',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: controller.formIsAvailable.value,
                            activeThumbColor: AppColors.primary,
                            onChanged: (val) => controller.formIsAvailable.value = val,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.4)),
            const SizedBox(height: 14),

            // BOTTOM ACTIONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isNew && selectedProd != null)
                  TextButton.icon(
                    onPressed: () {
                      Get.back();
                      _showDeleteConfirm(context, selectedProd, controller);
                    },
                    icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                    label: const Text('Delete Item', style: TextStyle(color: Colors.red, fontSize: 13)),
                  )
                else
                  const SizedBox(),

                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.onSurface,
                        side: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.6),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                          : () async {
                              await controller.saveProduct();
                              Get.back();
                            },
                      icon: controller.isSaving.value
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                      label: Text(
                        isNew ? 'Create Item' : 'Save Changes',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLabel(BuildContext context, String label) {
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

  void _showAddSizeModal(
    BuildContext context,
    MenuManagementController controller,
  ) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add Size Option'),
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
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
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
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
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
        title: const Text('Choose Preset Graphic'),
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

  void _showDeleteConfirm(
    BuildContext context,
    ProductModel product,
    MenuManagementController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Menu Item?'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
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
