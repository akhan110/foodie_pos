import 'package:flutter/material.dart';
import 'package:foodiepos/app/constants/storage_keys.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/app/widgets/custom_text_widget.dart';
import 'package:foodiepos/modules/shell/controller/main_shell_controller.dart';
import 'package:foodiepos/modules/shifts/controllers/shift_controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class CloseShiftDialog extends StatefulWidget {
  final ShiftController controller;
  final bool logoutOnClose;

  const CloseShiftDialog({
    super.key,
    required this.controller,
    this.logoutOnClose = true,
  });

  static Future<void> show(
    BuildContext context,
    ShiftController controller, {
    bool logoutOnClose = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 720),
          child: CloseShiftDialog(
            controller: controller,
            logoutOnClose: logoutOnClose,
          ),
        ),
      ),
    );
  }

  @override
  State<CloseShiftDialog> createState() => _CloseShiftDialogState();
}

class _CloseShiftDialogState extends State<CloseShiftDialog> {
  final TextEditingController closingCashController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  double countedCash = 0.0;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    widget.controller.fetchCurrentShift();
  }

  @override
  void dispose() {
    closingCashController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;
    final storage = GetStorage();
    final activeCashier = storage.read(StorageKeys.cashierName) ?? 'Akhan';

    return Obx(() {
      final shift = widget.controller.currentShift.value;

      final openingFloat = shift?.openingFloat ?? 5000.0;
      final expectedCash = shift?.expectedCash ?? openingFloat;
      final totalSales = shift?.totalSales ?? 0.0;
      final cashSales = shift?.cashSales ?? 0.0;
      final cardSales = shift?.cardSales ?? 0.0;
      final totalOrders = shift?.totalOrders ?? 0;
      final cashierName = shift?.cashierName ?? activeCashier;

      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1B1E26) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF2D333F) : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
              blurRadius: 36,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ============================================================
              // 1. TOP HEADER: Lock Icon, Title, Subtitle, Close Icon
              // ============================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.lock_clock_rounded,
                          color: Color(0xFFEF4444),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextWidget(
                            'Close Shift & Reconcile',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          CustomTextWidget(
                            'Cashier: $cashierName',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        size: 20,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ============================================================
              // 2. SUMMARY CARD (RECONCILIATION)
              // ============================================================
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141720) : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF282D3A) : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Column(
                  children: [
                    _summaryRow('Opening Cash Float', 'Rs ${openingFloat.toStringAsFixed(0)}', colors),
                    const SizedBox(height: 8),
                    _summaryRow('Total Orders Completed', '$totalOrders orders', colors),
                    const SizedBox(height: 8),
                    _summaryRow('Cash Sales', 'Rs ${cashSales.toStringAsFixed(0)}', colors),
                    const SizedBox(height: 8),
                    _summaryRow('Card / Digital Sales', 'Rs ${cardSales.toStringAsFixed(0)}', colors),
                    const SizedBox(height: 8),
                    _summaryRow(
                      'Gross Sales Revenue',
                      'Rs ${totalSales.toStringAsFixed(0)}',
                      colors,
                      isBold: true,
                    ),
                    const SizedBox(height: 16),
                    _summaryRow(
                      'Expected Cash in Drawer',
                      'Rs ${expectedCash.toStringAsFixed(0)}',
                      colors,
                      isBold: true,
                      valueColor: AppColors.primary,
                      fontSize: 14,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ============================================================
              // 3. ACTUAL CASH COUNTED IN DRAWER
              // ============================================================
              Text(
                'Actual Cash Counted in Drawer *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: closingCashController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
                onChanged: (val) {
                  setState(() {
                    countedCash = double.tryParse(val.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Enter counted amount',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF141720) : const Color(0xFFF3F4F6),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF282D3A) : const Color(0xFFE5E7EB),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF282D3A) : const Color(0xFFE5E7EB),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ============================================================
              // 4. CLOSING NOTES / REMARKS
              // ============================================================
              Text(
                'Closing Notes / Remarks',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 13,
                  color: colors.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. End of shift, handed drawer to Evening Cashier',
                  hintStyle: TextStyle(
                    fontSize: 12.5,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF141720) : const Color(0xFFF3F4F6),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF282D3A) : const Color(0xFFE5E7EB),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF282D3A) : const Color(0xFFE5E7EB),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ============================================================
              // 5. BOTTOM ACTIONS: Cancel & Close & End Shift
              // ============================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  ElevatedButton.icon(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            setState(() => isSubmitting = true);
                            final amount = double.tryParse(closingCashController.text.trim()) ?? expectedCash;
                            final notes = notesController.text.trim();

                            await widget.controller.closeShift(amount, notes: notes);

                            Get.back();

                            if (widget.logoutOnClose) {
                              if (Get.isRegistered<MainShellController>()) {
                                await Get.find<MainShellController>().logout();
                              } else {
                                final shellCtrl = Get.put(MainShellController());
                                await shellCtrl.logout();
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.lock_rounded, size: 16, color: Colors.white),
                    label: Text(
                      'Close & End Shift',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _summaryRow(
    String label,
    String value,
    ColorScheme colors, {
    bool isBold = false,
    Color? valueColor,
    double fontSize = 13,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: colors.onSurface,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? colors.onSurface,
          ),
        ),
      ],
    );
  }
}
