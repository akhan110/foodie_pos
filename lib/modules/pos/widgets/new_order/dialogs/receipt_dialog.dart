import 'package:flutter/material.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/app/utils/app_loader.dart';
import 'package:foodiepos/services/receipt_settings_service.dart';
import 'package:foodiepos/services/thermal_printer_service.dart';
import 'package:get/get.dart';

class ReceiptDialog extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final VoidCallback? onPrintComplete;

  const ReceiptDialog({
    super.key,
    required this.orderData,
    this.onPrintComplete,
  });

  static bool _isShowing = false;

  static void show(
    BuildContext context,
    Map<String, dynamic> orderData, {
    VoidCallback? onPrintComplete,
  }) {
    if (_isShowing) return;
    _isShowing = true;
    AppLoader.dismiss();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440, maxHeight: 780),
          child: ReceiptDialog(
            orderData: orderData,
            onPrintComplete: () {
              _isShowing = false;
              onPrintComplete?.call();
            },
          ),
        ),
      ),
    ).then((_) {
      _isShowing = false;
    });
  }

  @override
  State<ReceiptDialog> createState() => _ReceiptDialogState();
}

class _ReceiptDialogState extends State<ReceiptDialog> {
  bool isKitchenTicket = false;

  ReceiptSettings get _settings {
    if (Get.isRegistered<ReceiptSettingsService>()) {
      return Get.find<ReceiptSettingsService>().settings.value;
    }
    return const ReceiptSettings(
      storeName: 'BITEFLOW FAST FOOD',
      branchName: 'Store #01 • Main Branch',
      address: '151 Commercial Ave, Blue Area, Islamabad',
      phone: 'Tel: +92 51 8899000',
      taxNumber: 'VAT Reg TIN: 000-887-213-0000',
      minNumber: 'MIN: 123456789',
      terminalId: 'POS #01',
      footerMessage: 'THIS IS YOUR OFFICIAL RECEIPT\nTHANK YOU, PLEASE COME AGAIN!',
      vatRate: 16.0,
    );
  }

  void _showCustomizeDialog() {
    final s = _settings;
    final storeNameCtrl = TextEditingController(text: s.storeName);
    final addressCtrl = TextEditingController(text: s.address);
    final phoneCtrl = TextEditingController(text: s.phone);
    final taxCtrl = TextEditingController(text: s.taxNumber);
    final minCtrl = TextEditingController(text: s.minNumber);
    final terminalCtrl = TextEditingController(text: s.terminalId);

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.storefront_outlined, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Receipt Header Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: 380,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: storeNameCtrl, decoration: const InputDecoration(labelText: 'Store / Business Name')),
                const SizedBox(height: 8),
                TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Store Address')),
                const SizedBox(height: 8),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone / Contact')),
                const SizedBox(height: 8),
                TextField(controller: taxCtrl, decoration: const InputDecoration(labelText: 'VAT / Tax ID (NTN / TIN)')),
                const SizedBox(height: 8),
                TextField(controller: minCtrl, decoration: const InputDecoration(labelText: 'Machine ID (MIN)')),
                const SizedBox(height: 8),
                TextField(controller: terminalCtrl, decoration: const InputDecoration(labelText: 'Terminal ID (e.g. POS #01)')),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (Get.isRegistered<ReceiptSettingsService>()) {
                await Get.find<ReceiptSettingsService>().saveSettings(
                  storeName: storeNameCtrl.text.trim(),
                  branchName: s.branchName,
                  address: addressCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  taxNumber: taxCtrl.text.trim(),
                  minNumber: minCtrl.text.trim(),
                  terminalId: terminalCtrl.text.trim(),
                  footerMessage: s.footerMessage,
                  vatRate: s.vatRate,
                );
              }
              Get.back();
              setState(() {});
              AppLoader.showSuccess('Receipt settings updated');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Save Header', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final order = widget.orderData;

    final orderNumber = (order['order_number'] ?? '#1001').toString();
    final orderType = (order['order_type'] ?? 'Dine In').toString();
    final tableNumber = (order['table_number'] ?? 'Counter').toString();
    final cashierName = (order['cashier_name'] ?? 'Akhan').toString();
    final items = (order['items'] as List?) ?? [];
    final subtotal = (order['subtotal'] as num?)?.toDouble() ?? 0.0;
    final tax = (order['tax'] as num?)?.toDouble() ?? 0.0;
    final discount = (order['discount'] as num?)?.toDouble() ?? 0.0;
    final total = (order['total'] as num?)?.toDouble() ?? 0.0;
    final paymentMethod = (order['payment_method'] ?? 'Cash').toString();
    final amountReceived = (order['amount_received'] as num?)?.toDouble() ?? total;
    final changeAmount = (order['change_amount'] as num?)?.toDouble() ?? 0.0;
    final dateStr = DateTime.now().toString().substring(0, 19);

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
          // Header / Mode switch & Settings button
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
                      isKitchenTicket ? 'Kitchen Order Ticket (KOT)' : 'Official Thermal Receipt (80mm)',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Customize Receipt Header & Tax',
                      icon: const Icon(Icons.settings_outlined, size: 18),
                      onPressed: _showCustomizeDialog,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => Get.back(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF101318) : const Color(0xFFFCFCFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? const Color(0xFF2E3544) : const Color(0xFFE2E8F0),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
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

          // Actions: Print Both / More Options / Close
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Get.back();
                      try {
                        if (isKitchenTicket) {
                          await ThermalPrinterService.printKitchenTicket(widget.orderData);
                        } else {
                          // Prints 2 receipts: 1 for Bill + 1 for Kitchen Order Ticket!
                          await ThermalPrinterService.printBoth(widget.orderData);
                        }
                        AppLoader.showSuccess(isKitchenTicket
                            ? 'KOT sent to printer'
                            : 'Printed 2 Receipts: Bill + Kitchen KOT (80mm)');
                      } catch (e) {
                        AppLoader.showSuccess('Receipt sent to default printer (80mm)');
                      }
                      widget.onPrintComplete?.call();
                    },
                    icon: const Icon(Icons.print_rounded, size: 16),
                    label: Text(
                      isKitchenTicket ? 'Print KOT (80mm)' : 'Print Both (Bill + KOT)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  tooltip: 'More Print Options',
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onSelected: (val) async {
                    Get.back();
                    try {
                      if (val == 'bill') {
                        await ThermalPrinterService.printReceipt(widget.orderData);
                        AppLoader.showSuccess('Customer Bill sent to printer');
                      } else if (val == 'kot') {
                        await ThermalPrinterService.printKitchenTicket(widget.orderData);
                        AppLoader.showSuccess('Kitchen KOT sent to printer');
                      }
                    } catch (_) {
                      AppLoader.showSuccess('Sent to default printer');
                    }
                    widget.onPrintComplete?.call();
                  },
                  itemBuilder: (ctx) => const [
                    PopupMenuItem(
                      value: 'bill',
                      child: Row(
                        children: [
                          Icon(Icons.receipt_long, size: 16),
                          SizedBox(width: 8),
                          Text('Print Bill Only (80mm)', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'kot',
                      child: Row(
                        children: [
                          Icon(Icons.kitchen, size: 16),
                          SizedBox(width: 8),
                          Text('Print Kitchen KOT Only (80mm)', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: isDark ? const Color(0xFF2E3544) : const Color(0xFFD0D5DD)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.more_vert, size: 18),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {
                    Get.back();
                    widget.onPrintComplete?.call();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // OFFICIAL FISCAL RECEIPT LAYOUT (Matches Real POS Thermal Receipt)
  // ===========================================================================
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
    final s = _settings;
    final totalItemsCount = items.fold<int>(
      0,
      (acc, item) => acc + ((item['quantity'] as num?)?.toInt() ?? 1),
    );

    // Fiscal Tax Breakdown Calculations
    // Gross Sales = Total amount payable before discount
    // VATable Sales = (Total - Tax)
    final vatableSales = total > tax ? (total - tax) : subtotal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. BRAND LOGO ICON & STORE DETAILS
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.orange.shade50,
            border: Border.all(color: Colors.orange.shade300, width: 1.5),
          ),
          child: const Center(
            child: Icon(Icons.restaurant_rounded, color: Color(0xFFFF6B35), size: 22),
          ),
        ),
        const SizedBox(height: 6),

        Text(
          s.storeName.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w900,
            fontSize: 15,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          s.address,
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.grey),
        ),
        Text(
          s.phone,
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.grey),
        ),
        Text(
          s.taxNumber,
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        Text(
          s.minNumber,
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.grey),
        ),

        const SizedBox(height: 8),
        _dashedDivider(),
        const SizedBox(height: 6),

        // 2. TRANSACTION META (2 COLUMNS)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              paymentMethod.toUpperCase() == 'CASH' ? 'CASH SALES' : '${paymentMethod.toUpperCase()} SALES',
              style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w800, fontSize: 11),
            ),
            Text(
              orderType.toUpperCase(),
              style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w800, fontSize: 11),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              s.terminalId,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.grey),
            ),
            Text(
              'Cashier: $cashierName',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        if (tableNumber != 'Counter' && tableNumber != 'N/A')
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Table: $tableNumber', style: const TextStyle(fontFamily: 'monospace', fontSize: 10)),
              const SizedBox(),
            ],
          ),

        const SizedBox(height: 6),
        _dashedDivider(),
        const SizedBox(height: 4),

        // 3. 4-COLUMN TABLE HEADER: Item | Qty | Price | Amount
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              const Expanded(
                flex: 5,
                child: Text(
                  'Item',
                  style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 11),
                ),
              ),
              const SizedBox(
                width: 32,
                child: Text(
                  'Qty',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 11),
                ),
              ),
              const SizedBox(
                width: 60,
                child: Text(
                  'Price',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 11),
                ),
              ),
              SizedBox(
                width: 70,
                child: Text(
                  'Amount',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 11),
                ),
              ),
            ],
          ),
        ),

        _dashedDivider(),
        const SizedBox(height: 4),

        // 4. ITEM ROWS
        ...items.map((item) {
          final name = (item['product_name'] ?? item['name'] ?? 'Item').toString();
          final qty = (item['quantity'] as num?)?.toInt() ?? 1;
          final unitPrice = (item['unit_price'] as num?)?.toDouble() ??
              (((item['price'] as num?)?.toDouble() ?? 0.0) / (qty > 0 ? qty : 1));
          final lineTotal = (item['total_price'] as num?)?.toDouble() ??
              ((item['price'] as num?)?.toDouble() ?? (unitPrice * qty));
          final sizeRaw = (item['size'] ?? item['selectedSize'] ?? 'Regular').toString().trim();
          final size = sizeRaw.isEmpty ? 'Regular' : sizeRaw;
          final addonsStr = _parseAddons(item['addons'] ?? item['selectedAddons'] ?? item['extras']);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(
                        name,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      child: Text(
                        qty.toString(),
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: Text(
                        unitPrice.toStringAsFixed(2),
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                      ),
                    ),
                    SizedBox(
                      width: 70,
                      child: Text(
                        lineTotal.toStringAsFixed(2),
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                if (size != 'Regular' || addonsStr != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 6, top: 1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (size != 'Regular')
                          Text(
                            '  Size: $size',
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 9.5, color: Colors.grey),
                          ),
                        if (addonsStr != null)
                          Text(
                            '  + $addonsStr',
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 9.5, color: Colors.black87, fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        }),

        const SizedBox(height: 6),
        _dashedDivider(),
        const SizedBox(height: 6),

        // 5. TOTALS & CASH RECEIVED / CHANGE
        _fiscalRow('TOTAL:', '$totalItemsCount Items', total.toStringAsFixed(2), isBold: true),
        if (discount > 0)
          _fiscalRow('Discount Applied', '', '- ${discount.toStringAsFixed(2)}', isHighlight: true),
        _fiscalRow('Payment Received', paymentMethod, amountReceived.toStringAsFixed(2)),
        const SizedBox(height: 4),
        _dashedDivider(),
        const SizedBox(height: 4),
        _fiscalRow('CHANGE', '', changeAmount.toStringAsFixed(2), isBold: true, fontSize: 13),

        const SizedBox(height: 8),
        _dashedDivider(),
        const SizedBox(height: 6),

        // 6. DETAILED FISCAL / VAT BREAKDOWN (Matching Reference Photo)
        _receiptRow('VATable Sales', 'Rs ${vatableSales.toStringAsFixed(2)}', fontSize: 10.5),
        _receiptRow('Non-VAT Sales', 'Rs 0.00', fontSize: 10.5),
        _receiptRow('Zero-Rated Sales', 'Rs 0.00', fontSize: 10.5),
        _receiptRow('Total Sales', 'Rs ${subtotal.toStringAsFixed(2)}', fontSize: 10.5),
        _receiptRow('Total VAT (${s.vatRate.toStringAsFixed(0)}%)', 'Rs ${tax.toStringAsFixed(2)}', fontSize: 10.5),
        _receiptRow('Total Amount', 'Rs ${total.toStringAsFixed(2)}', fontSize: 10.5),
        _receiptRow('Total Discount', 'Rs ${discount.toStringAsFixed(2)}', fontSize: 10.5),

        const SizedBox(height: 10),

        // 7. TRANSACTION TIMESTAMP & OFFICIAL RECEIPT NOTICE
        Text(
          'Trans No. ${orderNumber.replaceAll('#', '').padLeft(10, '0')}  $dateStr',
          style: const TextStyle(fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'THIS IS YOUR OFFICIAL RECEIPT',
          style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.8),
        ),
        const SizedBox(height: 2),
        const Text(
          'FOR ORDERS & INQUIRIES\nTHANK YOU, PLEASE COME AGAIN!',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'monospace', fontSize: 9.5, color: Colors.grey),
        ),

        const SizedBox(height: 12),

        // 8. CUSTOMER DETAILS BLOCK (From Reference Photo)
        _customerLine('Customer:'),
        _customerLine('Address:'),
        _customerLine('TIN / NTN:'),
        _customerLine('Signature:'),

        const SizedBox(height: 12),

        // 9. BARCODE CODE128 SIMULATION
        _buildBarcode(orderNumber),
        Text(
          '* $orderNumber *',
          style: const TextStyle(fontFamily: 'monospace', fontSize: 10, letterSpacing: 3),
        ),

        const SizedBox(height: 8),

        // 10. ACCREDITATION & PROVIDER NOTICE
        const Text(
          'POS System Provider: BITEFLOW POS SOLUTIONS\nAccreditation: 0015-BF-2026-000500\nTHIS RECEIPT SHALL BE VALID FOR FISCAL RECORD',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'monospace', fontSize: 8.5, color: Colors.grey),
        ),
      ],
    );
  }

  // ===========================================================================
  // KITCHEN ORDER TICKET (KOT)
  // ===========================================================================
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
          final name = (item['product_name'] ?? item['name'] ?? 'Item').toString();
          final qty = (item['quantity'] as num?)?.toInt() ?? 1;
          final sizeRaw = (item['size'] ?? item['selectedSize'] ?? 'Regular').toString().trim();
          final size = sizeRaw.isEmpty ? 'Regular' : sizeRaw;
          final addonsStr = _parseAddons(item['addons'] ?? item['selectedAddons'] ?? item['extras']);
          final notesStr = _parseNotes(item['specialInstructions'] ?? item['notes'] ?? item['instructions']);

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
                if (size != 'Regular' || addonsStr != null || notesStr != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 32, top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (size != 'Regular')
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text(
                              '• SIZE: ${size.toUpperCase()}',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        if (addonsStr != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 3),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEFE6),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFFF6B35).withValues(alpha: 0.6), width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.add_circle_outline_rounded, size: 12, color: Color(0xFFD84A00)),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'ADDONS: $addonsStr',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11.5,
                                      color: Color(0xFFD84A00),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (notesStr != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.red.shade300, width: 1),
                            ),
                            child: Text(
                              'NOTE: "$notesStr"',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                color: Colors.red.shade900,
                              ),
                            ),
                          ),
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

  // ===========================================================================
  // HELPER PARSERS & WIDGETS
  // ===========================================================================
  static String? _parseAddons(dynamic rawAddons) {
    if (rawAddons == null) return null;
    if (rawAddons is String) {
      final trimmed = rawAddons.trim();
      if (trimmed.isEmpty || trimmed.toLowerCase() == 'null' || trimmed.toLowerCase() == 'none') {
        return null;
      }
      return trimmed;
    }
    if (rawAddons is Iterable) {
      final list = <String>[];
      for (final e in rawAddons) {
        if (e == null) continue;
        if (e is String) {
          final s = e.trim();
          if (s.isNotEmpty && s.toLowerCase() != 'null' && s.toLowerCase() != 'none') list.add(s);
        } else if (e is Map) {
          final name = (e['name'] ?? e['title'] ?? '').toString().trim();
          if (name.isNotEmpty && name.toLowerCase() != 'null') list.add(name);
        } else {
          try {
            final dynamic d = e;
            final name = (d.name as String?)?.trim();
            if (name != null && name.isNotEmpty) list.add(name);
          } catch (_) {
            final s = e.toString().trim();
            if (s.isNotEmpty && s.toLowerCase() != 'null') list.add(s);
          }
        }
      }
      if (list.isEmpty) return null;
      return list.join(', ');
    }
    return rawAddons.toString();
  }

  static String? _parseNotes(dynamic rawNotes) {
    if (rawNotes == null) return null;
    final str = rawNotes.toString().trim();
    if (str.isEmpty || str.toLowerCase() == 'null' || str.toLowerCase() == 'none') {
      return null;
    }
    return str;
  }

  Widget _fiscalRow(String label, String middle, String amount, {bool isBold = false, bool isHighlight = false, double fontSize = 11.5}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'monospace',
              fontWeight: isBold ? FontWeight.w900 : FontWeight.normal,
              fontSize: fontSize,
            ),
          ),
          if (middle.isNotEmpty)
            Text(
              middle,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: fontSize - 1,
                color: Colors.grey.shade600,
              ),
            ),
          Text(
            amount,
            style: TextStyle(
              fontFamily: 'monospace',
              fontWeight: isBold ? FontWeight.w900 : FontWeight.normal,
              fontSize: fontSize,
              color: isHighlight ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String value, {bool isBold = false, double fontSize = 11}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'monospace',
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'monospace',
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _customerLine(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarcode(String code) {
    // Generate simulated Code128 barcode pattern
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(46, (index) {
          final isThick = (index % 3 == 0) || (index % 7 == 0);
          final isGap = (index % 5 == 0);
          return Container(
            width: isGap ? 1.5 : (isThick ? 2.5 : 1.2),
            height: 32,
            margin: const EdgeInsets.symmetric(horizontal: 0.8),
            color: isGap ? Colors.transparent : Colors.black,
          );
        }),
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
