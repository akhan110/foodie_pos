import 'package:flutter/material.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/app/widgets/app_image_widget.dart';
import 'package:foodiepos/app/widgets/custom_text_widget.dart';
import 'package:foodiepos/modules/pos/controllers/pos_controller.dart';
import 'package:foodiepos/modules/pos/model/cart_model.dart';
import 'package:get/get.dart';

class PaymentView extends GetView<PosController> {
  const PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: BACK BUTTON, TITLE, SUBTITLE
          Row(
            children: [
              InkWell(
                onTap: controller.cancelPayment,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E222B) : const Color(0xFFF4F6F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? const Color(0xFF2D333F) : theme.dividerColor,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 20,
                    color: colors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextWidget(
                    'Payment',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  CustomTextWidget(
                    'Choose how the customer wants to pay',
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // MAIN 2-COLUMN PAYMENT WORKSPACE
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT SECTION: PAYMENT METHODS & CASH / SPLIT INPUT
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // PAYMENT METHOD TILES ROW
                        _buildPaymentMethodsRow(context),

                        const SizedBox(height: 20),

                        // CASH / PAYMENT / SPLIT INPUT CARD
                        _buildPaymentInputCard(context),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                // RIGHT SECTION: ORDER SUMMARY CARD
                Expanded(
                  flex: 4,
                  child: _buildOrderSummaryCard(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsRow(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedPaymentMethod.value;
      final mode = controller.paymentMode.value;

      return Row(
        children: [
          Expanded(
            child: _buildMethodTile(
              context: context,
              title: 'Cash',
              subtitle: 'Pay with cash',
              iconWidget: const Text('💵', style: TextStyle(fontSize: 22)),
              isSelected: mode == 'single' && selected == 'Cash',
              onTap: () {
                controller.paymentMode.value = 'single';
                controller.selectPaymentMethod('Cash');
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMethodTile(
              context: context,
              title: 'Card',
              subtitle: 'Debit / credit',
              iconWidget: const Icon(Icons.credit_card_rounded, size: 22, color: Color(0xFF3B82F6)),
              isSelected: mode == 'single' && selected == 'Card',
              onTap: () {
                controller.paymentMode.value = 'single';
                controller.selectPaymentMethod('Card');
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMethodTile(
              context: context,
              title: 'QR Pay',
              subtitle: 'Scan and pay',
              iconWidget: const Icon(Icons.qr_code_2_rounded, size: 22, color: Color(0xFF8B5CF6)),
              isSelected: mode == 'single' && selected == 'QR Pay',
              onTap: () {
                controller.paymentMode.value = 'single';
                controller.selectPaymentMethod('QR Pay');
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMethodTile(
              context: context,
              title: 'Split',
              subtitle: 'Cash + Card',
              iconWidget: const Icon(Icons.pie_chart_outline_rounded, size: 22, color: Color(0xFFF59E0B)),
              isSelected: mode == 'split',
              onTap: () {
                controller.paymentMode.value = 'split';
                controller.splitCashAmount.value = (controller.total / 2).roundToDouble();
                controller.splitCardAmount.value = controller.total - controller.splitCashAmount.value;
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildMethodTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Widget iconWidget,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final baseBg = isDark ? const Color(0xFF1E222B) : Colors.white;
    final activeBorder = isSelected ? AppColors.primary : (isDark ? const Color(0xFF2D333F) : theme.dividerColor);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        constraints: const BoxConstraints(minHeight: 96),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: baseBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: activeBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            const SizedBox(height: 4),
            CustomTextWidget(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.primary : colors.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            CustomTextWidget(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInputCard(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF1E222B) : Colors.white;
    final inputBg = isDark ? const Color(0xFF252A36) : const Color(0xFFF4F6F9);

    return Obx(() {
      final isSplit = controller.paymentMode.value == 'split';
      final isCash = controller.paymentMode.value == 'single' && controller.selectedPaymentMethod.value == 'Cash';
      final totalAmount = controller.total;
      final change = controller.changeAmount;
      final isPlacing = controller.isPlacingOrder.value;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF2D333F) : theme.dividerColor,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isSplit) ...[
              CustomTextWidget(
                'SPLIT PAYMENT (CASH + CARD)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 14),

              // Split Cash Input
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Cash Portion (Rs)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: inputBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: TextFormField(
                            initialValue: controller.splitCashAmount.value.toStringAsFixed(0),
                            keyboardType: TextInputType.number,
                            onChanged: (val) {
                              final cash = double.tryParse(val) ?? 0.0;
                              controller.splitCashAmount.value = cash;
                              controller.splitCardAmount.value = (totalAmount - cash).clamp(0.0, totalAmount);
                            },
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            decoration: const InputDecoration(border: InputBorder.none, prefixText: 'Rs '),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Card Portion (Rs)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: inputBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Obx(() => Text(
                                  'Rs ${controller.splitCardAmount.value.toStringAsFixed(0)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3B82F6)),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              CustomTextWidget(
                isCash ? 'CASH RECEIVED' : '${controller.selectedPaymentMethod.value.toUpperCase()} PAYMENT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),

              // LARGE CASH INPUT CONTAINER
              Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2D333F) : theme.dividerColor.withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  children: [
                    CustomTextWidget(
                      'Rs ',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: controller.cashReceivedController,
                        enabled: isCash,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: controller.onCashInputChanged,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: colors.onSurface,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (isCash) ...[
                const SizedBox(height: 14),

                // QUICK DENOMINATION SUGGESTION PILLS
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildQuickPill(
                      context: context,
                      label: 'Exact (Rs ${totalAmount.toStringAsFixed(0)})',
                      onTap: () => controller.setCashReceived(totalAmount),
                    ),
                    _buildQuickPill(
                      context: context,
                      label: '+ Rs 100',
                      onTap: () => controller.addCashPreset(100),
                    ),
                    _buildQuickPill(
                      context: context,
                      label: '+ Rs 500',
                      onTap: () => controller.addCashPreset(500),
                    ),
                    _buildQuickPill(
                      context: context,
                      label: '+ Rs 1,000',
                      onTap: () => controller.addCashPreset(1000),
                    ),
                    _buildQuickPill(
                      context: context,
                      label: '+ Rs 5,000',
                      onTap: () => controller.addCashPreset(5000),
                    ),
                  ],
                ),
              ],
            ],

            const SizedBox(height: 28),

            // BOTTOM ROW: CHANGE AMOUNT & COMPLETE ORDER BUTTON
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextWidget(
                      'Change',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    CustomTextWidget(
                      isSplit ? 'Rs 0' : 'Rs ${change.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),

                // COMPLETE ORDER BUTTON
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: isPlacing ? null : controller.completeOrder,
                    icon: isPlacing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded, size: 18),
                    label: const CustomTextWidget(
                      'Complete Order ✓',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildQuickPill({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF252A36) : const Color(0xFFF1F3F7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? const Color(0xFF2D333F) : theme.dividerColor,
          ),
        ),
        child: CustomTextWidget(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF1E222B) : Colors.white;

    return Obx(() {
      final items = controller.cartItems;
      final subtotal = controller.subtotal;
      final tax = controller.tax;
      final discount = controller.discountAmount;
      final total = controller.total;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF2D333F) : theme.dividerColor,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showDiscountModal(context),
                  icon: const Icon(Icons.local_offer_outlined, size: 14),
                  label: Text(
                    discount > 0 ? '${controller.discountValue.value.toInt()}% Off' : '+ Discount',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    minimumSize: Size.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // CART ITEMS LIST
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: CustomTextWidget(
                        'No items in cart',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    )
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _buildSummaryItemTile(context, item);
                      },
                    ),
            ),

            const SizedBox(height: 16),
            Divider(height: 1, color: isDark ? const Color(0xFF2D333F) : theme.dividerColor),
            const SizedBox(height: 14),

            // BREAKDOWN
            _buildSummaryRow('Subtotal', 'Rs ${subtotal.toStringAsFixed(0)}', colors),
            if (discount > 0) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('Discount', style: TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: controller.removeDiscount,
                        child: const Icon(Icons.cancel, size: 14, color: Colors.redAccent),
                      ),
                    ],
                  ),
                  Text('- Rs ${discount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
            const SizedBox(height: 6),
            _buildSummaryRow('Tax (16% GST)', 'Rs ${tax.toStringAsFixed(0)}', colors),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  'Total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
                CustomTextWidget(
                  'Rs ${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryItemTile(BuildContext context, CartItemModel item) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final tileBg = isDark ? const Color(0xFF252A36) : const Color(0xFFF9FAFB);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: tileBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2D333F) : theme.dividerColor.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: [
          // THUMBNAIL with universal AppImageWidget
          Container(
            width: 38,
            height: 38,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: AppImageWidget(
              imagePath: item.product.image,
              width: 38,
              height: 38,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),

          // NAME & SIZE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextWidget(
                  item.product.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                CustomTextWidget(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // QUANTITY STEPPER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E222B) : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: isDark ? const Color(0xFF2D333F) : theme.dividerColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => controller.decrementCartItem(item.id),
                  child: Icon(Icons.remove, size: 12, color: colors.onSurfaceVariant),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: CustomTextWidget(
                    '${item.quantity}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => controller.incrementCartItem(item.id),
                  child: Icon(Icons.add, size: 12, color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // PRICE
          CustomTextWidget(
            'Rs ${item.subtotal.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, ColorScheme colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomTextWidget(
          label,
          style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
        ),
        CustomTextWidget(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.onSurface),
        ),
      ],
    );
  }

  void _showDiscountModal(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Apply Order Discount'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  label: const Text('5% Off'),
                  onPressed: () {
                    controller.applyDiscount('percent', 5);
                    Get.back();
                  },
                ),
                ActionChip(
                  label: const Text('10% Off'),
                  onPressed: () {
                    controller.applyDiscount('percent', 10);
                    Get.back();
                  },
                ),
                ActionChip(
                  label: const Text('15% Off'),
                  onPressed: () {
                    controller.applyDiscount('percent', 15);
                    Get.back();
                  },
                ),
                ActionChip(
                  label: const Text('Rs 100 Flat'),
                  onPressed: () {
                    controller.applyDiscount('flat', 100);
                    Get.back();
                  },
                ),
                ActionChip(
                  label: const Text('Rs 200 Flat'),
                  onPressed: () {
                    controller.applyDiscount('flat', 200);
                    Get.back();
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.removeDiscount();
              Get.back();
            },
            child: const Text('Remove Discount', style: TextStyle(color: Colors.redAccent)),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
