import 'package:flutter/material.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/app/widgets/custom_text_widget.dart';
import 'package:foodiepos/modules/pos/controllers/pos_controller.dart';
import 'package:foodiepos/modules/pos/widgets/new_order/right_view_cart/cart_item_list.dart';
import 'package:foodiepos/modules/pos/widgets/new_order/right_view_cart/order_type_tabs.dart';
import 'package:get/get.dart';

class CartSection extends GetView<PosController> {
  const CartSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          children: [
            // HEADER
            Row(
              children: [
                Expanded(
                  child: CustomTextWidget(
                    'Current Order',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                ),

                Obx(() {
                  if (controller.cartItems.isEmpty) return const SizedBox.shrink();
                  return TextButton(
                    onPressed: controller.clearCart,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const CustomTextWidget(
                      'Clear all',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 10),

            const Align(
              alignment: Alignment.centerLeft,
              child: OrderTypeTabs(),
            ),
            const SizedBox(height: 12),

            // CART LIST
            const Expanded(child: CartItemList()),

            const SizedBox(height: 12),

            // CART TOTALS SUMMARY
            _buildCartSummary(context, colors, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, ColorScheme colors, ThemeData theme) {
    return Obx(() {
      final subtotal = controller.subtotal;
      final tax = controller.tax;
      final total = controller.total;
      final itemCount = controller.cartItems.fold(0, (sum, i) => sum + i.quantity);

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          children: [
            // SUBTOTAL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  'Subtotal ($itemCount items)',
                  style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                ),
                CustomTextWidget(
                  'Rs ${subtotal.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // TAX
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  'Tax (16% GST)',
                  style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                ),
                CustomTextWidget(
                  'Rs ${tax.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.onSurface),
                ),
              ],
            ),

            Divider(height: 16, color: theme.dividerColor),

            // TOTAL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  'Total Amount',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: colors.onSurface),
                ),
                CustomTextWidget(
                  'Rs ${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // CHARGE / CHECKOUT BUTTON
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: controller.cartItems.isEmpty ? null : controller.openPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: colors.onSurface.withValues(alpha: 0.12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: CustomTextWidget(
                  itemCount > 0 ? 'Charge  •  Rs ${total.toStringAsFixed(0)}' : 'No Items in Cart',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
