import 'package:flutter/material.dart';
import 'package:foodiepos/app/constants/storage_keys.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/app/utils/app_loader.dart';
import 'package:foodiepos/app/widgets/custom_text_widget.dart';
import 'package:foodiepos/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:foodiepos/modules/deals/controllers/deals_controller.dart';
import 'package:foodiepos/modules/menu/controllers/menu_management_controller.dart';
import 'package:foodiepos/modules/orders/controllers/orders_controller.dart';
import 'package:foodiepos/modules/pos/controllers/pos_controller.dart';
import 'package:foodiepos/modules/pos/widgets/new_order/dialogs/receipt_dialog.dart';
import 'package:foodiepos/modules/shifts/controllers/shift_controller.dart';
import 'package:foodiepos/services/network/api_request_type.dart';
import 'package:foodiepos/services/network/network.dart';
import 'package:foodiepos/services/receipt_settings_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  int selectedTabIndex = 0; // 0: Shift Control, 1: Store & Receipt, 2: Data & Reset

  // Shift tab controllers
  final TextEditingController countedCashController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  double countedCash = 34900.0;
  bool isClosing = false;

  // Store & Receipt tab controllers
  late TextEditingController storeNameCtrl;
  late TextEditingController branchNameCtrl;
  late TextEditingController addressCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController taxCtrl;
  late TextEditingController minCtrl;
  late TextEditingController terminalCtrl;
  late TextEditingController footerCtrl;
  late TextEditingController vatRateCtrl;

  bool isResetting = false;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ShiftController>()) {
      Get.put(ShiftController());
    }

    final shiftCtrl = Get.find<ShiftController>();
    countedCashController.text = 'Rs 34,900';
    notesController.text = 'Drawer checked and balanced.';

    shiftCtrl.fetchCurrentShift().then((_) {
      final shift = shiftCtrl.currentShift.value;
      if (shift != null && mounted) {
        final expected = shift.expectedCash;
        final formatted = 'Rs ${_formatCurrency(expected)}';
        countedCashController.text = formatted;
        setState(() {
          countedCash = expected;
        });
      }
    });

    _initStoreControllers();
  }

  void _initStoreControllers() {
    ReceiptSettings s;
    if (Get.isRegistered<ReceiptSettingsService>()) {
      s = Get.find<ReceiptSettingsService>().settings.value;
    } else {
      s = const ReceiptSettings(
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

    storeNameCtrl = TextEditingController(text: s.storeName);
    branchNameCtrl = TextEditingController(text: s.branchName);
    addressCtrl = TextEditingController(text: s.address);
    phoneCtrl = TextEditingController(text: s.phone);
    taxCtrl = TextEditingController(text: s.taxNumber);
    minCtrl = TextEditingController(text: s.minNumber);
    terminalCtrl = TextEditingController(text: s.terminalId);
    footerCtrl = TextEditingController(text: s.footerMessage);
    vatRateCtrl = TextEditingController(text: s.vatRate.toStringAsFixed(0));
  }

  @override
  void dispose() {
    countedCashController.dispose();
    notesController.dispose();
    storeNameCtrl.dispose();
    branchNameCtrl.dispose();
    addressCtrl.dispose();
    phoneCtrl.dispose();
    taxCtrl.dispose();
    minCtrl.dispose();
    terminalCtrl.dispose();
    footerCtrl.dispose();
    vatRateCtrl.dispose();
    super.dispose();
  }

  String _formatCurrency(num amount) {
    final str = amount.abs().toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '09:00 AM';
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  double _parseCashInput(String text) {
    final clean = text.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(clean) ?? 0.0;
  }

  // ===========================================================================
  // DATA RESET API & SYNC
  // ===========================================================================
  Future<void> _executeReset(String target, String label) async {
    try {
      setState(() => isResetting = true);
      AppLoader.show(status: 'Resetting $label...');

      final resp = await Network.instance.apiRequest<Map<String, dynamic>>(
        requestType: ApiRequestType.post,
        endPoint: '/api/v1/system/reset-data',
        requestData: {'target': target},
        isBearerRequired: false,
        parser: (data) => data is Map<String, dynamic> ? data : {},
      );

      if (resp.success) {
        // Refresh all controllers live
        if (Get.isRegistered<PosController>()) {
          Get.find<PosController>().loadMenuData();
          Get.find<PosController>().clearCart();
        }
        if (Get.isRegistered<MenuManagementController>()) {
          Get.find<MenuManagementController>().loadMenu();
        }
        if (Get.isRegistered<OrdersController>()) {
          Get.find<OrdersController>().loadOrders(showLoading: false);
        }
        if (Get.isRegistered<DealsController>()) {
          Get.find<DealsController>().fetchDeals(showSpinner: false);
        }
        if (Get.isRegistered<ShiftController>()) {
          Get.find<ShiftController>().fetchCurrentShift();
        }
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().fetchAnalytics();
        }

        AppLoader.showSuccess('$label complete! System refreshed.');
      } else {
        AppLoader.showError(resp.message.isNotEmpty ? resp.message : 'Reset failed');
      }
    } catch (e) {
      AppLoader.showError('Reset failed: $e');
    } finally {
      if (mounted) {
        setState(() => isResetting = false);
      }
    }
  }

  void _confirmReset(BuildContext context, {required String target, required String title, required String message, bool isDanger = false}) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isDanger ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
              color: isDanger ? const Color(0xFFEF4444) : AppColors.primary,
              size: 26,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 13.5, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _executeReset(target, title);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDanger ? const Color(0xFFEF4444) : AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              isDanger ? 'Yes, Reset' : 'Confirm',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: isDark ? const Color(0xFF10151E) : const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================================
            // 1. PAGE HEADER & NAVIGATION TABS
            // ============================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextWidget(
                      'Settings & Controls',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: primaryTextColor,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    CustomTextWidget(
                      'Configure shifts, store receipt details, and data management',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),

                // TABS SEGMENT
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E222B) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTabBtn(0, 'Shift Control', Icons.point_of_sale_rounded, isDark),
                      _buildTabBtn(1, 'Store & Receipt', Icons.receipt_long_rounded, isDark),
                      _buildTabBtn(2, 'Data & Reset', Icons.restart_alt_rounded, isDark, isHighlight: true),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ============================================================
            // 2. ACTIVE TAB CONTENT
            // ============================================================
            if (selectedTabIndex == 0)
              _buildShiftControlTab(context, isDark, primaryTextColor, secondaryTextColor)
            else if (selectedTabIndex == 1)
              _buildStoreReceiptTab(context, isDark, primaryTextColor, secondaryTextColor)
            else
              _buildDataResetTab(context, isDark, primaryTextColor, secondaryTextColor),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBtn(int index, String label, IconData icon, bool isDark, {bool isHighlight = false}) {
    final isSelected = selectedTabIndex == index;
    return InkWell(
      onTap: () => setState(() => selectedTabIndex = index),
      borderRadius: BorderRadius.circular(9),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF2A313F) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? (isHighlight ? const Color(0xFFEF4444) : AppColors.primary)
                  : (isDark ? Colors.grey : const Color(0xFF64748B)),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.white : Colors.black87)
                    : (isDark ? Colors.grey : const Color(0xFF64748B)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 0: SHIFT CONTROL
  // ===========================================================================
  Widget _buildShiftControlTab(
    BuildContext context,
    bool isDark,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    final storage = GetStorage();
    final cashierName = storage.read(StorageKeys.cashierName) ?? 'Akhan';
    final cashierStore = storage.read(StorageKeys.cashierStore) ?? 'Store #01';
    final cashierRole = storage.read(StorageKeys.cashierRole) ?? 'Cashier';

    final shiftController = Get.find<ShiftController>();

    final cardBg = isDark ? const Color(0xFF1E222B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2D333F) : const Color(0xFFE2E8F0);
    final inputBg = isDark ? const Color(0xFF141720) : const Color(0xFFF1F5F9);
    final reconcileBoxBg = isDark ? const Color(0xFF141720) : const Color(0xFFF8FAFC);
    final dividerColor = isDark ? const Color(0xFF282D3A) : const Color(0xFFF1F5F9);

    return Obx(() {
      final shift = shiftController.currentShift.value;
      final isOpen = shift == null || shift.status.toLowerCase() == 'open';

      final openingCash = shift?.openingFloat ?? 10000.0;
      final cashSales = shift?.cashSales ?? 24860.0;
      final expectedDrawer = shift != null ? shift.expectedCash : (openingCash + cashSales);
      final startTime = shift?.openedAt != null ? _formatTime(shift!.openedAt) : '09:00 AM';
      final diff = countedCash - expectedDrawer;

      final diffText = diff == 0
          ? 'Rs 0'
          : (diff > 0
              ? '+ Rs ${_formatCurrency(diff)}'
              : '- Rs ${_formatCurrency(-diff)}');
      final diffColor = diff >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444);

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT CARD: Current shift Info
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFFF97316),
                        child: const Text('AK', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cashierName, style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: primaryTextColor)),
                          const SizedBox(height: 2),
                          Text('$cashierStore • $cashierRole', style: TextStyle(fontSize: 13, color: secondaryTextColor)),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOpen ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: isOpen ? const Color(0xFF16A34A) : const Color(0xFFDC2626))),
                            const SizedBox(width: 6),
                            Text(isOpen ? 'Active Shift' : 'Closed', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: isOpen ? const Color(0xFF15803D) : const Color(0xFFB91C1C))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(color: dividerColor, height: 1),
                  _buildTableRow('Shift Started', startTime, primaryTextColor, secondaryTextColor),
                  Divider(color: dividerColor, height: 1),
                  _buildTableRow('Opening Cash Float', 'Rs ${_formatCurrency(openingCash)}', primaryTextColor, secondaryTextColor),
                  Divider(color: dividerColor, height: 1),
                  _buildTableRow('Cash Sales Today', 'Rs ${_formatCurrency(cashSales)}', primaryTextColor, secondaryTextColor),
                  Divider(color: dividerColor, height: 1),
                  _buildTableRow('Expected in Drawer', 'Rs ${_formatCurrency(expectedDrawer)}', const Color(0xFFF97316), secondaryTextColor),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),

          // RIGHT CARD: Reconcile & Close Shift
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('COUNTED DRAWER CASH', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: secondaryTextColor)),
                  const SizedBox(height: 7),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: inputBg, borderRadius: BorderRadius.circular(10)),
                    child: TextField(
                      controller: countedCashController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: primaryTextColor),
                      decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 14)),
                      onChanged: (val) {
                        setState(() {
                          countedCash = _parseCashInput(val);
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: reconcileBoxBg, borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Reconciliation Variance', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: secondaryTextColor)),
                        Text(diffText, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: diffColor)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('SHIFT NOTE (OPTIONAL)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: secondaryTextColor)),
                  const SizedBox(height: 7),
                  Container(
                    height: 68,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: inputBg, borderRadius: BorderRadius.circular(10)),
                    child: TextField(
                      controller: notesController,
                      maxLines: 2,
                      style: TextStyle(fontSize: 13.5, color: isDark ? Colors.white : const Color(0xFF334155)),
                      decoration: InputDecoration(
                        hintText: 'Drawer checked and balanced.',
                        hintStyle: TextStyle(fontSize: 13.5, color: secondaryTextColor.withValues(alpha: 0.7)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isClosing
                        ? null
                        : () async {
                            setState(() => isClosing = true);
                            final amount = countedCash > 0 ? countedCash : expectedDrawer;
                            final notes = notesController.text.trim();
                            await shiftController.closeShift(amount, notes: notes);
                            setState(() => isClosing = false);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53E3E),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: isClosing
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Close Shift & Print Report', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  // ===========================================================================
  // TAB 1: STORE & RECEIPT CONFIGURATION
  // ===========================================================================
  Widget _buildStoreReceiptTab(
    BuildContext context,
    bool isDark,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    final cardBg = isDark ? const Color(0xFF1E222B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2D333F) : const Color(0xFFE2E8F0);
    final inputBg = isDark ? const Color(0xFF141720) : const Color(0xFFF1F5F9);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEFT COLUMN: Business Header & Contact
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Business & Branch Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: primaryTextColor)),
                const SizedBox(height: 4),
                Text('These appear at the top of your printed 80mm thermal receipts', style: TextStyle(fontSize: 12.5, color: secondaryTextColor)),
                const SizedBox(height: 18),
                _formField('Store / Restaurant Name', storeNameCtrl, inputBg, primaryTextColor),
                const SizedBox(height: 12),
                _formField('Branch / Location', branchNameCtrl, inputBg, primaryTextColor),
                const SizedBox(height: 12),
                _formField('Physical Address', addressCtrl, inputBg, primaryTextColor),
                const SizedBox(height: 12),
                _formField('Phone / Hotline', phoneCtrl, inputBg, primaryTextColor),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20),

        // RIGHT COLUMN: Tax & Fiscal IDs
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fiscal & Tax Registration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: primaryTextColor)),
                const SizedBox(height: 4),
                Text('Compliance numbers printed on receipts', style: TextStyle(fontSize: 12.5, color: secondaryTextColor)),
                const SizedBox(height: 18),
                _formField('VAT Reg TIN / NTN', taxCtrl, inputBg, primaryTextColor),
                const SizedBox(height: 12),
                _formField('Machine Identification (MIN)', minCtrl, inputBg, primaryTextColor),
                const SizedBox(height: 12),
                _formField('Terminal ID (e.g. POS #01)', terminalCtrl, inputBg, primaryTextColor),
                const SizedBox(height: 12),
                _formField('Sales Tax Rate (%)', vatRateCtrl, inputBg, primaryTextColor),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final vat = double.tryParse(vatRateCtrl.text.trim()) ?? 16.0;
                          if (Get.isRegistered<ReceiptSettingsService>()) {
                            await Get.find<ReceiptSettingsService>().saveSettings(
                              storeName: storeNameCtrl.text.trim(),
                              branchName: branchNameCtrl.text.trim(),
                              address: addressCtrl.text.trim(),
                              phone: phoneCtrl.text.trim(),
                              taxNumber: taxCtrl.text.trim(),
                              minNumber: minCtrl.text.trim(),
                              terminalId: terminalCtrl.text.trim(),
                              footerMessage: footerCtrl.text.trim(),
                              vatRate: vat,
                            );
                          }
                          AppLoader.showSuccess('Store receipt details saved!');
                        },
                        icon: const Icon(Icons.check_circle_outline, size: 16),
                        label: const Text('Save Details', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () {
                        // Launch sample receipt preview
                        final sampleOrder = {
                          'order_number': '#1001',
                          'order_type': 'Dine In',
                          'table_number': 'Table 1',
                          'cashier_name': 'Akhan',
                          'subtotal': 1490.0,
                          'tax': 238.4,
                          'discount': 0.0,
                          'total': 1728.4,
                          'payment_method': 'Cash',
                          'amount_received': 2000.0,
                          'change_amount': 271.6,
                          'items': [
                            {'product_name': 'Double Smash Deluxe', 'quantity': 1, 'unit_price': 890.0, 'total_price': 890.0, 'size': 'Large'},
                            {'product_name': 'Crispy Chicken Burger', 'quantity': 1, 'unit_price': 580.0, 'total_price': 580.0},
                            {'product_name': 'Chilled Cola 500ml', 'quantity': 1, 'unit_price': 120.0, 'total_price': 120.0},
                          ],
                        };
                        ReceiptDialog.show(context, sampleOrder);
                      },
                      icon: const Icon(Icons.visibility_outlined, size: 16),
                      label: const Text('Preview'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _formField(String label, TextEditingController ctrl, Color bg, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.grey)),
        const SizedBox(height: 5),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
          child: TextField(
            controller: ctrl,
            style: TextStyle(fontSize: 13.5, color: textColor),
            decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 12)),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // TAB 2: DATA & TOTAL SYSTEM RESET
  // ===========================================================================
  Widget _buildDataResetTab(
    BuildContext context,
    bool isDark,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    final cardBg = isDark ? const Color(0xFF1E222B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2D333F) : const Color(0xFFE2E8F0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Notice Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF231818) : const Color(0xFFFFF1F2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF43F5E).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFF43F5E), size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Administrative Data & Clean Slate Controls', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFFF43F5E))),
                    const SizedBox(height: 2),
                    Text(
                      'Use these options to wipe test data, clear order history, or completely reset all products and categories so you can create your own custom restaurant menu.',
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : const Color(0xFF881337)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Grid of Reset Actions
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Option 1: Clear Orders & Shift History
            Expanded(
              child: _buildActionCard(
                title: 'Clear Orders & Shifts',
                subtitle: 'Deletes all customer orders, receipts, and closed shifts. Keeps your menu products, categories, deals, and cashier accounts intact.',
                icon: Icons.receipt_long_outlined,
                iconColor: const Color(0xFFF97316),
                btnText: 'Clear Orders History',
                btnColor: const Color(0xFFF97316),
                cardBg: cardBg,
                borderColor: borderColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                onTap: () => _confirmReset(
                  context,
                  target: 'orders',
                  title: 'Clear Orders & Shifts',
                  message: 'Are you sure you want to permanently clear all past orders and shift history? This action cannot be undone.',
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Option 2: Clear Menu & Deals
            Expanded(
              child: _buildActionCard(
                title: 'Clear Menu & Categories',
                subtitle: 'Deletes all products, categories, addons, size options, and combo deals so you can build your own restaurant menu from a clean slate.',
                icon: Icons.restaurant_menu_rounded,
                iconColor: const Color(0xFFEAB308),
                btnText: 'Clear Menu & Categories',
                btnColor: const Color(0xFFCA8A04),
                cardBg: cardBg,
                borderColor: borderColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                onTap: () => _confirmReset(
                  context,
                  target: 'menu',
                  title: 'Clear Menu & Deals',
                  message: 'Are you sure you want to delete all menu items and categories? A single empty "General" category will be created so you can start adding your own products.',
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Option 3: TOTAL CLEAN SLATE (FACTORY RESET)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF261515) : const Color(0xFFFFF5F5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.5), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.15), shape: BoxShape.circle),
                          child: const Icon(Icons.delete_forever_rounded, color: Color(0xFFEF4444), size: 22),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'TOTAL FACTORY RESET (CLEAN SLATE)',
                            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: Color(0xFFDC2626), letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Permanently wipes EVERYTHING: All products, categories, combo deals, customer orders, and shifts. Resets the database to a completely blank slate so you can enter your own business data from zero. Your active cashier account remains logged in.',
                      style: TextStyle(fontSize: 12.5, height: 1.4, color: isDark ? Colors.grey.shade300 : const Color(0xFF7F1D1D)),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: isResetting
                          ? null
                          : () => _confirmReset(
                                context,
                                target: 'all',
                                title: 'Total Clean Slate Reset',
                                message: 'DANGER: This will delete ALL products, categories, deals, orders, and shifts permanently. You will have a completely empty POS database ready for your own data.\n\nAre you sure you want to proceed?',
                                isDanger: true,
                              ),
                      icon: const Icon(Icons.delete_sweep_rounded, size: 16),
                      label: const Text('Reset Everything to Clean Slate', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Option 4: Restore Sample Demo Data
            Expanded(
              child: _buildActionCard(
                title: 'Restore Sample Fast-Food Data',
                subtitle: 'Want to test with sample items again later? This restores the default smash burgers, pizzas, sides, beverages, and categories with demo images.',
                icon: Icons.fastfood_rounded,
                iconColor: const Color(0xFF3B82F6),
                btnText: 'Restore Demo Menu Data',
                btnColor: const Color(0xFF2563EB),
                cardBg: cardBg,
                borderColor: borderColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                onTap: () => _confirmReset(
                  context,
                  target: 'seed',
                  title: 'Restore Demo Data',
                  message: 'This will replace existing items with the default demo smash burgers, pizzas, sides, and drinks. Proceed?',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String btnText,
    required Color btnColor,
    required Color cardBg,
    required Color borderColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: primaryTextColor)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(subtitle, style: TextStyle(fontSize: 12.5, height: 1.4, color: secondaryTextColor)),
          const SizedBox(height: 18),
          OutlinedButton(
            onPressed: isResetting ? null : onTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: btnColor,
              side: BorderSide(color: btnColor),
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
            ),
            child: Text(btnText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(String label, String value, Color primaryColor, Color secondaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: secondaryColor)),
          Text(value, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: primaryColor)),
        ],
      ),
    );
  }
}
