import 'package:flutter/material.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/app/widgets/custom_text_widget.dart';
import 'package:foodiepos/modules/pos/controllers/pos_controller.dart';
import 'package:foodiepos/modules/pos/widgets/new_order/dialogs/parked_orders_dialog.dart';
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
            // HEADER: TITLE + PARKED BADGE + HOLD / CLEAR
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: CustomTextWidget(
                          'Current Order',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colors.onSurface,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // PARKED ORDERS BADGE
                      Obx(() {
                        final count = controller.parkedOrders.length;
                        if (count == 0) return const SizedBox.shrink();
                        return InkWell(
                          onTap: () => ParkedOrdersDialog.show(context, controller),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.pause, size: 11, color: Colors.white),
                                const SizedBox(width: 2),
                                Text(
                                  'Parked: $count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(width: 4),

                // HOLD / PARK ORDER BUTTON
                Obx(() {
                  if (controller.cartItems.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Hold Order Button
                      InkWell(
                        onTap: () => controller.parkCurrentOrder(),
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.pause_circle_filled, size: 14, color: AppColors.primary),
                              SizedBox(width: 2),
                              Text(
                                'Hold',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),

                      // Clear All Button
                      InkWell(
                        onTap: controller.clearCart,
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                          child: CustomTextWidget(
                            'Clear',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
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
      final discount = controller.discountAmount;
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

            // DISCOUNT (IF APPLIED)
            if (discount > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('Discount', style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: controller.removeDiscount,
                        child: const Icon(Icons.cancel, size: 12, color: Colors.redAccent),
                      ),
                    ],
                  ),
                  Text(
                    '- Rs ${discount.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],

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
