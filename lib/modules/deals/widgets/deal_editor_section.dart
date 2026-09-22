import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodiepos/modules/deals/controllers/deals_controller.dart';
import 'package:foodiepos/modules/pos/controllers/pos_controller.dart';
import 'package:get/get.dart';

class DealEditorSection extends GetView<DealsController> {
  const DealEditorSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E222B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A313F) : const Color(0xFFEAECF0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ===================================================================
          // 1. HEADER: Deal Details + Delete Deal
          // ===================================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deal Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Create or update deal information.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Obx(() {
                  final canDelete = controller.selectedDeal.value != null && !controller.isCreatingNew.value;
                  if (!canDelete) return const SizedBox.shrink();

                  return OutlinedButton.icon(
                    onPressed: () => _confirmDelete(context),
                    icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFF04438)),
                    label: const Text(
                      'Delete Deal',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF04438),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFDA29B)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1),

          // ===================================================================
          // 2. SCROLLABLE FORM BODY
          // ===================================================================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Upper Grid: Left Image box / Right Form fields
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Deal Image Upload Box
                      Expanded(
                        flex: 42,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Deal Image',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: colors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildImageBox(context),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Right Form Fields
                      Expanded(
                        flex: 58,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Deal Name
                            _buildLabel(context, 'Deal Name', isRequired: true),
                            const SizedBox(height: 6),
                            Container(
                              height: 42,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF13171F) : const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF2A313F) : const Color(0xFFD0D5DD),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: TextField(
                                controller: controller.nameController,
                                decoration: const InputDecoration(
                                  hintText: 'e.g. Burger Combo',
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 11),
                                ),
                                style: TextStyle(fontSize: 13, color: colors.onSurface),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Category
                            _buildLabel(context, 'Category', isRequired: true),
                            const SizedBox(height: 6),
                            Obx(() {
                              return Container(
                                height: 42,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF13171F) : const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF2A313F) : const Color(0xFFD0D5DD),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: controller.category.value,
                                    isExpanded: true,
                                    icon: Icon(Icons.keyboard_arrow_down, size: 18, color: colors.onSurfaceVariant),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: colors.onSurface,
                                    ),
                                    dropdownColor: isDark ? const Color(0xFF1E222B) : Colors.white,
                                    items: controller.availableCategories.map((cat) {
                                      return DropdownMenuItem(
                                        value: cat,
                                        child: Row(
                                          children: [
                                            const Text('🎁', style: TextStyle(fontSize: 14)),
                                            const SizedBox(width: 8),
                                            Text(cat),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) controller.category.value = val;
                                    },
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 14),

                            // Status Switch Toggle
                            _buildLabel(context, 'Status'),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Obx(() {
                                  return Switch(
                                    value: controller.isActive.value,
                                    activeThumbColor: const Color(0xFFFF6B35),
                                    onChanged: (val) => controller.isActive.value = val,
                                  );
                                }),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Obx(() => Text(
                                          controller.isActive.value ? 'Active' : 'Inactive',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: colors.onSurface,
                                          ),
                                        )),
                                    Text(
                                      'When disabled, this deal will not appear in POS.',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ===========================================================
                  // 3. DEAL ITEMS TABLE
                  // ===========================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Deal Items',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Add products to this deal.',
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showAddProductDialog(context),
                        icon: const Icon(Icons.add, size: 16, color: Colors.white),
                        label: const Text(
                          'Add Item',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Items Table
                  _buildItemsTable(context),

                  const SizedBox(height: 20),

                  // ===========================================================
                  // 4. PRICING SUMMARY & PREVIEW
                  // ===========================================================
                  _buildPricingAndPreview(context),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // ===================================================================
          // 5. BOTTOM ACTION FOOTER
          // ===================================================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    if (controller.selectedDeal.value != null) {
                      controller.selectDeal(controller.selectedDeal.value!);
                    } else {
                      controller.startNewDeal();
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Obx(() {
                  return ElevatedButton.icon(
                    onPressed: controller.isSaving.value ? null : () => controller.saveDeal(),
                    icon: controller.isSaving.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.save_outlined, size: 16, color: Colors.white),
                    label: Text(
                      controller.isSaving.value ? 'Saving...' : 'Save Deal',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text, {bool isRequired = false}) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
        if (isRequired)
          const Text(
            ' *',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFF04438)),
          ),
      ],
    );
  }

  Widget _buildImageBox(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13171F) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2A313F) : const Color(0xFFEAECF0),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Image Box with edit pencil badge
          Stack(
            children: [
              Container(
                height: 110,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E222B) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2A313F) : const Color(0xFFEAECF0),
                  ),
                ),
                child: Center(
                  child: Obx(() {
                    final path = controller.imageUrl.value;
                    if (path.endsWith('.svg')) {
                      return SvgPicture.asset(path, width: 64, height: 64, fit: BoxFit.contain);
                    }
                    return Image.asset(path, fit: BoxFit.contain);
                  }),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.edit, size: 14, color: Color(0xFF344054)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Change Image Button
          OutlinedButton.icon(
            onPressed: () => _selectPresetImage(context),
            icon: const Icon(Icons.upload_outlined, size: 14, color: Color(0xFF344054)),
            label: const Text(
              'Change Image',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF344054)),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFD0D5DD)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'JPG, PNG (Max 2MB)',
            style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13171F) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF2A313F) : const Color(0xFFEAECF0),
        ),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E222B) : const Color(0xFFF2F4F7),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    'Product',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors.onSurfaceVariant),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Price',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors.onSurfaceVariant),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Text(
                      'Quantity',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors.onSurfaceVariant),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Total',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors.onSurfaceVariant),
                  ),
                ),
                const SizedBox(
                  width: 32,
                  child: Center(
                    child: Text(
                      'Action',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF667085)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Items Rows
          Obx(() {
            if (controller.draftItems.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No items added yet. Click "+ Add Item" above.',
                    style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.draftItems.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: isDark ? const Color(0xFF2A313F) : const Color(0xFFEAECF0),
              ),
              itemBuilder: (context, index) {
                final item = controller.draftItems[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    children: [
                      // Product Thumbnail + Name
                      Expanded(
                        flex: 5,
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E222B) : Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: isDark ? const Color(0xFF2A313F) : const Color(0xFFEAECF0)),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: item.productImage.endsWith('.svg')
                                    ? Center(child: SvgPicture.asset(item.productImage, width: 20, height: 20))
                                    : Image.asset(item.productImage, fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.productName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: colors.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Price
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Rs ${item.unitPrice.toStringAsFixed(0)}',
                          style: TextStyle(fontSize: 12, color: colors.onSurface),
                        ),
                      ),

                      // Stepper: [-] qty [+]
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E222B) : Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: isDark ? const Color(0xFF2A313F) : const Color(0xFFD0D5DD)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () => controller.decrementItemQty(index),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    child: Icon(Icons.remove, size: 12),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Text(
                                    '${item.quantity}',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: colors.onSurface),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => controller.incrementItemQty(index),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    child: Icon(Icons.add, size: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Total
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Rs ${(item.unitPrice * item.quantity).toStringAsFixed(0)}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: colors.onSurface),
                        ),
                      ),

                      // Trash Button
                      SizedBox(
                        width: 32,
                        child: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFF04438)),
                          onPressed: () => controller.removeItem(index),
                          padding: EdgeInsets.zero,
                          tooltip: 'Remove',
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPricingAndPreview(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pricing Calculations
        Expanded(
          flex: 55,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF13171F) : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF2A313F) : const Color(0xFFEAECF0),
              ),
            ),
            child: Column(
              children: [
                // Original Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Original Total',
                      style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
                    ),
                    Obx(() => Text(
                          'Rs ${controller.originalTotal.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: colors.onSurface,
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 12),

                // Deal Price Input
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLabel(context, 'Deal Price', isRequired: true),
                    SizedBox(
                      width: 120,
                      height: 38,
                      child: TextField(
                        controller: controller.priceController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.end,
                        decoration: InputDecoration(
                          hintText: '799',
                          prefixText: 'Rs ',
                          prefixStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.onSurface),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1E222B) : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: isDark ? const Color(0xFF2A313F) : const Color(0xFFD0D5DD)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          isDense: true,
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                        onChanged: (_) => controller.priceController.text = controller.priceController.text,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Customer Saves Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Customer Saves',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF12B76A)),
                    ),
                    Obx(() {
                      final saves = controller.customerSaves;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8FDF2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Rs ${saves.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF12B76A),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Deal Preview Box
        Expanded(
          flex: 45,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF13171F) : const Color(0xFFFFF9F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF2A313F) : const Color(0xFFFFD7C2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_offer, size: 14, color: Color(0xFFFF6B35)),
                    const SizedBox(width: 6),
                    Text(
                      'Deal Preview',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'This is how it will appear in the POS.',
                  style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 10),

                // Mini Preview Card
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E222B) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? const Color(0xFF2A313F) : const Color(0xFFEAECF0),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF13171F) : const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Obx(() {
                            final p = controller.imageUrl.value;
                            return p.endsWith('.svg')
                                ? Center(child: SvgPicture.asset(p, width: 28, height: 28))
                                : Image.asset(p, fit: BoxFit.cover);
                          }),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() => Text(
                                  controller.nameController.text.isNotEmpty
                                      ? controller.nameController.text
                                      : 'Burger Combo',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: colors.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )),
                            const SizedBox(height: 2),
                            Obx(() => Text(
                                  controller.generatedDescription,
                                  style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )),
                            const SizedBox(height: 2),
                            Obx(() => Text(
                                  'Rs ${controller.priceController.text.isNotEmpty ? controller.priceController.text : "799"}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFFF6B35),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final posCtrl = Get.isRegistered<PosController>() ? Get.find<PosController>() : null;
    final products = posCtrl?.allProducts ?? [];

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.add_shopping_cart, color: Color(0xFFFF6B35)),
              SizedBox(width: 10),
              Text('Add Product to Deal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ),
          content: SizedBox(
            width: 440,
            height: 380,
            child: products.isNotEmpty
                ? ListView.separated(
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final prod = products[index];
                      return ListTile(
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: prod.image.endsWith('.svg')
                                ? Center(child: SvgPicture.asset(prod.image, width: 24, height: 24))
                                : Image.asset(prod.image, fit: BoxFit.cover),
                          ),
                        ),
                        title: Text(prod.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        subtitle: Text('Rs ${prod.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: Color(0xFF667085))),
                        trailing: ElevatedButton(
                          onPressed: () {
                            controller.addProductToDeal(prod);
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B35),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            elevation: 0,
                          ),
                          child: const Text('Add', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Quick Add Standard Item:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _quickAddItemButton(ctx, 'Classic Smash Burger', 620, 'assets/svg/products/burger.svg'),
                            _quickAddItemButton(ctx, 'Sea Salt Fries', 260, 'assets/svg/products/fries.svg'),
                            _quickAddItemButton(ctx, 'Cola', 180, 'assets/svg/products/drink.svg'),
                            _quickAddItemButton(ctx, 'Pepperoni Pizza', 890, 'assets/svg/products/pizza.svg'),
                            _quickAddItemButton(ctx, 'Crunch Chicken', 740, 'assets/svg/products/chicken.svg'),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _quickAddItemButton(BuildContext ctx, String name, double price, String img) {
    return ElevatedButton(
      onPressed: () {
        controller.addCustomItem(name: name, price: price, image: img);
        Navigator.pop(ctx);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF2F4F7),
        foregroundColor: const Color(0xFF344054),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text('$name (Rs ${price.toStringAsFixed(0)})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  void _selectPresetImage(BuildContext context) {
    final presets = [
      {'name': 'Burger Combo', 'path': 'assets/svg/products/burger.svg'},
      {'name': 'Pizza Deal', 'path': 'assets/svg/products/pizza.svg'},
      {'name': 'Chicken Meal', 'path': 'assets/svg/products/chicken.svg'},
      {'name': 'Drink Offer', 'path': 'assets/svg/products/drink.svg'},
      {'name': 'Fries Snack', 'path': 'assets/svg/products/fries.svg'},
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Select Deal Image', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          content: SizedBox(
            width: 360,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: presets.map((p) {
                return InkWell(
                  onTap: () {
                    controller.imageUrl.value = p['path']!;
                    Navigator.pop(ctx);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 100,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFEAECF0)),
                    ),
                    child: Column(
                      children: [
                        SvgPicture.asset(p['path']!, width: 44, height: 44),
                        const SizedBox(height: 6),
                        Text(p['name']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Deal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFFF04438))),
        content: Text('Are you sure you want to delete "${controller.nameController.text}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.deleteDeal();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF04438)),
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
