import 'package:flutter/material.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/app/utils/app_loader.dart';
import 'package:get/get.dart';

class ReceiptDialog extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final VoidCallback? onPrintComplete;

  const ReceiptDialog({
    super.key,
    required this.orderData,
    this.onPrintComplete,
  });

  static void show(BuildContext context, Map<String, dynamic> orderData, {VoidCallback? onPrintComplete}) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 680),
          child: ReceiptDialog(
            orderData: orderData,
            onPrintComplete: onPrintComplete,
          ),
        ),
      ),
    );
  }

  @override
  State<ReceiptDialog> createState() => _ReceiptDialogState();
}

class _ReceiptDialogState extends State<ReceiptDialog> {
  bool isKitchenTicket = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final order = widget.orderData;

    final orderNumber = order['order_number'] ?? '#1001';
    final orderType = order['order_type'] ?? 'Dine In';
    final tableNumber = order['table_number'] ?? 'Table 1';
    final cashierName = order['cashier_name'] ?? 'Alex Khan';
    final items = (order['items'] as List?) ?? [];
    final subtotal = (order['subtotal'] as num?)?.toDouble() ?? 0.0;
    final tax = (order['tax'] as num?)?.toDouble() ?? 0.0;
    final discount = (order['discount'] as num?)?.toDouble() ?? 0.0;
    final total = (order['total'] as num?)?.toDouble() ?? 0.0;
    final paymentMethod = order['payment_method'] ?? 'Cash';
    final amountReceived = (order['amount_received'] as num?)?.toDouble() ?? total;
    final changeAmount = (order['change_amount'] as num?)?.toDouble() ?? 0.0;
    final dateStr = DateTime.now().toString().substring(0, 16);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E222B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header / Mode switch
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF15181E) : const Color(0xFFF6F8FA),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isKitchenTicket ? Icons.restaurant_menu_rounded : Icons.receipt_long_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isKitchenTicket ? 'Kitchen Order Ticket (KOT)' : 'Customer Thermal Receipt',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => Get.back(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Toggle Mode
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Customer Receipt', style: TextStyle(fontSize: 12)),
                  icon: Icon(Icons.receipt, size: 14),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Kitchen KOT', style: TextStyle(fontSize: 12)),
                  icon: Icon(Icons.kitchen, size: 14),
                ),
              ],
              selected: {isKitchenTicket},
              onSelectionChanged: (val) {
                setState(() {
                  isKitchenTicket = val.first;
                });
              },
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: AppColors.primary.withValues(alpha: 0.15),
                selectedForegroundColor: AppColors.primary,
              ),
            ),
          ),

          // Thermal paper receipt preview
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111419) : const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? const Color(0xFF2E3544) : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: SingleChildScrollView(
                child: isKitchenTicket
                    ? _buildKitchenTicketContent(
                        orderNumber: orderNumber,
                        orderType: orderType,
                        tableNumber: tableNumber,
                        dateStr: dateStr,
                        items: items,
                      )
                    : _buildCustomerReceiptContent(
                        orderNumber: orderNumber,
                        orderType: orderType,
                        tableNumber: tableNumber,
                        cashierName: cashierName,
                        dateStr: dateStr,
                        items: items,
                        subtotal: subtotal,
                        tax: tax,
                        discount: discount,
                        total: total,
                        paymentMethod: paymentMethod,
                        amountReceived: amountReceived,
                        changeAmount: changeAmount,
                      ),
              ),
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.back();
                      AppLoader.showSuccess('Receipt sent to default printer');
                      widget.onPrintComplete?.call();
                    },
                    icon: const Icon(Icons.print_rounded, size: 16),
                    label: const Text('Print Now (80mm)'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    widget.onPrintComplete?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerReceiptContent({
    required String orderNumber,
    required String orderType,
    required String tableNumber,
    required String cashierName,
    required String dateStr,
    required List items,
    required double subtotal,
    required double tax,
    required double discount,
    required double total,
    required String paymentMethod,
    required double amountReceived,
    required double changeAmount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'BITEFLOW FAST FOOD',
          style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5),
        ),
        const Text(
          'Store #01 • F-7 Markaz, Islamabad',
          style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.grey),
        ),
        const Text(
          'Tel: +92 51 8899000 • NTN: 8872134-9',
          style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        _dashedDivider(),
        const SizedBox(height: 6),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ORDER: $orderNumber', style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 12)),
            Text(orderType.toUpperCase(), style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 11)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Table: $tableNumber', style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
            Text('Cashier: $cashierName', style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Date: $dateStr', style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.grey)),
            const Text('Status: PAID', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 10, color: Colors.green)),
          ],
        ),

        const SizedBox(height: 6),
        _dashedDivider(),
        const SizedBox(height: 6),

        // Item Lines
        ...items.map((item) {
          final name = item['product_name'] ?? item['name'] ?? 'Item';
          final qty = item['quantity'] ?? 1;
          final price = (item['total_price'] as num?)?.toDouble() ?? (item['price'] as num?)?.toDouble() ?? 0.0;
          final size = item['size'] ?? item['selectedSize'] ?? 'Regular';
          final addons = item['addons'] ?? item['selectedAddons'];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '$qty x $name',
                        style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'Rs ${price.toStringAsFixed(0)}',
                      style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
                if (size != 'Regular' || addons != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      '[$size${addons != null ? ' • $addons' : ''}]',
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.grey),
                    ),
                  ),
              ],
            ),
          );
        }),

        const SizedBox(height: 6),
        _dashedDivider(),
        const SizedBox(height: 6),

        // Financials
        _receiptRow('Subtotal', 'Rs ${subtotal.toStringAsFixed(0)}'),
        if (discount > 0)
          _receiptRow('Discount', '- Rs ${discount.toStringAsFixed(0)}', isHighlight: true),
        _receiptRow('Tax (16% GST)', 'Rs ${tax.toStringAsFixed(0)}'),
        const SizedBox(height: 4),
        _dashedDivider(),
        const SizedBox(height: 4),
        _receiptRow('TOTAL DUE', 'Rs ${total.toStringAsFixed(0)}', isBold: true, fontSize: 14),
        const SizedBox(height: 4),
        _dashedDivider(),
        const SizedBox(height: 4),
        _receiptRow('Paid by', paymentMethod),
        if (paymentMethod.toLowerCase() == 'cash') ...[
          _receiptRow('Cash Received', 'Rs ${amountReceived.toStringAsFixed(0)}'),
          _receiptRow('Change Due', 'Rs ${changeAmount.toStringAsFixed(0)}', isBold: true),
        ],

        const SizedBox(height: 12),
        const Text(
          '*** THANK YOU FOR YOUR VISIT ***',
          style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 11),
        ),
        const Text(
          'Powered by BiteFlow POS System',
          style: TextStyle(fontFamily: 'monospace', fontSize: 9, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildKitchenTicketContent({
    required String orderNumber,
    required String orderType,
    required String tableNumber,
    required String dateStr,
    required List items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '*** KITCHEN ORDER TICKET ***',
              style: TextStyle(fontFamily: 'monospace', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('KOT: $orderNumber', style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 16)),
            Text(tableNumber.toUpperCase(), style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
          ],
        ),
        Text('Type: $orderType | Time: $dateStr', style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 8),
        _dashedDivider(),
        const SizedBox(height: 8),

        ...items.map((item) {
          final name = item['product_name'] ?? item['name'] ?? 'Item';
          final qty = item['quantity'] ?? 1;
          final size = item['size'] ?? item['selectedSize'] ?? 'Regular';
          final addons = item['addons'] ?? item['selectedAddons'];
          final notes = item['specialInstructions'] ?? item['notes'];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${qty}x',
                        style: const TextStyle(fontFamily: 'monospace', color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                if (size != 'Regular' || addons != null || notes != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 32, top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (size != 'Regular')
                          Text('• SIZE: $size', style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w600, fontSize: 11)),
                        if (addons != null)
                          Text('• ADDONS: $addons', style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w600, fontSize: 11, color: Colors.orange)),
                        if (notes != null)
                          Text('• NOTE: "$notes"', style: const TextStyle(fontFamily: 'monospace', fontStyle: FontStyle.italic, fontSize: 11, color: Colors.redAccent)),
                      ],
                    ),
                  ),
              ],
            ),
          );
        }),

        const SizedBox(height: 10),
        _dashedDivider(),
        const SizedBox(height: 8),
        const Center(
          child: Text('--- END OF KITCHEN TICKET ---', style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.grey)),
        ),
      ],
    );
  }

  Widget _receiptRow(String label, String value, {bool isBold = false, bool isHighlight = false, double fontSize = 12}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'monospace',
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize,
              color: isHighlight ? Colors.green : null,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'monospace',
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize,
              color: isHighlight ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashedDivider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        final count = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(count, (_) {
            return const SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey)),
            );
          }),
        );
      },
    );
  }
}
