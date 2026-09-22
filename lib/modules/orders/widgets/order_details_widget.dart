import 'package:flutter/material.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/app/widgets/app_image_widget.dart';
import 'package:foodiepos/app/widgets/custom_text_widget.dart';
import 'package:foodiepos/modules/orders/controllers/orders_controller.dart';
import 'package:foodiepos/modules/orders/models/order_model.dart';
import 'package:get/get.dart';

class OrderDetailsWidget extends GetView<OrdersController> {
  const OrderDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final order = controller.selectedOrder.value;
      if (order == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CustomTextWidget('No order selected'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: controller.backToOrdersList,
                child: const CustomTextWidget('Back to Orders'),
              ),
            ],
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER BAR: BACK BUTTON, TITLE, SUBTITLE & ACTION BUTTONS
            _buildHeaderBar(context, order),

            const SizedBox(height: 20),

            // MAIN TWO-COLUMN CONTENT
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LEFT COLUMN: ORDER ITEMS & PRICE BREAKDOWN
                  Expanded(
                    flex: 6,
                    child: _buildItemsCard(context, order),
                  ),

                  const SizedBox(width: 20),

                  // RIGHT COLUMN: ORDER INFORMATION & PAYMENT
                  Expanded(
                    flex: 4,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildOrderInfoCard(context, order),
                          const SizedBox(height: 20),
                          _buildPaymentCard(context, order),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHeaderBar(BuildContext context, OrderModel order) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final isVoided = order.status.toLowerCase() == 'voided';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // BACK BUTTON & ORDER TITLE / SUBTITLE
        Row(
          children: [
            InkWell(
              onTap: controller.backToOrdersList,
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
                  'Order ${order.orderNumber}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                CustomTextWidget(
                  order.formattedCompletedSubtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),

        // ACTIONS: REPRINT RECEIPT & VOID ORDER
        Row(
          children: [
            OutlinedButton(
              onPressed: () => controller.reprintReceipt(order),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.onSurface,
                side: BorderSide(
                  color: isDark ? const Color(0xFF2D333F) : theme.dividerColor,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const CustomTextWidget(
                'Reprint receipt',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: isVoided ? null : () => controller.voidOrder(order),
              style: ElevatedButton.styleFrom(
                backgroundColor: isVoided ? Colors.grey : const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: CustomTextWidget(
                isVoided ? 'Order Voided' : 'Void order',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemsCard(BuildContext context, OrderModel order) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF1E222B) : Colors.white;

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
          CustomTextWidget(
            'Items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // LIST OF ITEMS
          Expanded(
            child: order.items.isEmpty
                ? Center(
                    child: CustomTextWidget(
                      'No item details available',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: order.items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = order.items[index];
                      return _buildItemTile(context, item);
                    },
                  ),
          ),

          const SizedBox(height: 16),
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? const Color(0xFF2D333F) : theme.dividerColor,
          ),
          const SizedBox(height: 14),

          // SUMMARY BREAKDOWN
          _buildSummaryRow('Subtotal', order.formattedSubtotal, colors),
          const SizedBox(height: 8),
          _buildSummaryRow('Tax', order.formattedTax, colors),
          const SizedBox(height: 8),
          _buildSummaryRow('Discount', order.formattedDiscount, colors),
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
                order.formattedTotal,
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
  }

  Widget _buildItemTile(BuildContext context, OrderItemModel item) {
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
          // PRODUCT THUMBNAIL
          Container(
            width: 42,
            height: 42,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: AppImageWidget(
              imagePath: item.productImage,
              fit: BoxFit.contain,
              borderRadius: BorderRadius.circular(8),
              fallbackIconSize: 20,
            ),
          ),

          const SizedBox(width: 14),

          // PRODUCT NAME & VARIANT / ADDONS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextWidget(
                  item.productName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                CustomTextWidget(
                  item.addons != null && item.addons!.isNotEmpty
                      ? '${item.size} • ${item.addons}'
                      : item.size,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // QUANTITY INDICATOR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E222B) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? const Color(0xFF2D333F) : theme.dividerColor,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.remove, size: 12, color: colors.onSurfaceVariant),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: CustomTextWidget(
                    '${item.quantity}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                ),
                Icon(Icons.add, size: 12, color: colors.onSurfaceVariant),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // ITEM TOTAL PRICE
          CustomTextWidget(
            item.formattedTotalPrice,
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

  Widget _buildSummaryRow(String label, String value, ColorScheme colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomTextWidget(
          label,
          style: TextStyle(
            fontSize: 13,
            color: colors.onSurfaceVariant,
          ),
        ),
        CustomTextWidget(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderInfoCard(BuildContext context, OrderModel order) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF1E222B) : Colors.white;

    return Container(
      width: double.infinity,
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
          CustomTextWidget(
            'Order Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // STATUS ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextWidget(
                'Status',
                style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: order.statusBadgeBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CustomTextWidget(
                  order.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: order.statusBadgeTextColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ORDER TYPE ROW
          _buildInfoRow('Order type', order.orderType, colors),

          const SizedBox(height: 14),

          // TABLE ROW
          _buildInfoRow('Table', order.tableNumber ?? 'Table 1', colors),

          const SizedBox(height: 14),

          // CASHIER ROW
          _buildInfoRow('Cashier', order.cashierName, colors),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, OrderModel order) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF1E222B) : Colors.white;

    return Container(
      width: double.infinity,
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
          CustomTextWidget(
            'Payment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // PAYMENT METHOD
          _buildInfoRow('Method', order.paymentMethod, colors),

          const SizedBox(height: 14),

          // AMOUNT RECEIVED
          _buildInfoRow('Received', order.formattedReceived, colors),

          const SizedBox(height: 14),

          // CHANGE AMOUNT
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextWidget(
                'Change',
                style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
              ),
              CustomTextWidget(
                order.formattedChange,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ColorScheme colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomTextWidget(
          label,
          style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
        ),
        CustomTextWidget(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
      ],
    );
  }
}
