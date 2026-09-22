import 'package:flutter/material.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/modules/shifts/controllers/shift_controller.dart';
import 'package:get/get.dart';

class CloseShiftDialog extends StatefulWidget {
  final ShiftController controller;

  const CloseShiftDialog({super.key, required this.controller});

  static void show(BuildContext context, ShiftController controller) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 680),
          child: CloseShiftDialog(controller: controller),
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

    return Obx(() {
      final shift = widget.controller.currentShift.value;

      if (shift == null) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E222B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No Active Shift Found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: () => Get.back(), child: const Text('Close')),
            ],
          ),
        );
      }

      final openingFloat = shift.openingFloat;
      final expectedCash = shift.expectedCash;
      final totalSales = shift.totalSales;
      final cashSales = shift.cashSales;
      final cardSales = shift.cardSales;
      final totalOrders = shift.totalOrders;
      final diff = countedCash - expectedCash;

      return Container(
        padding: const EdgeInsets.all(24),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.lock_clock_rounded, color: Colors.redAccent, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Close Shift & Reconcile',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            'Cashier: ${shift.cashierName}',
                            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => Get.back()),
                ],
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.4)),
              const SizedBox(height: 14),

              // Shift summary card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    _summaryRow('Opening Cash Float', 'Rs ${openingFloat.toStringAsFixed(0)}'),
                    _summaryRow('Total Orders Completed', '$totalOrders orders'),
                    _summaryRow('Cash Sales', 'Rs ${cashSales.toStringAsFixed(0)}'),
                    _summaryRow('Card / Digital Sales', 'Rs ${cardSales.toStringAsFixed(0)}'),
                    _summaryRow('Gross Sales Revenue', 'Rs ${totalSales.toStringAsFixed(0)}', isBold: true),
                    const Divider(height: 16),
                    _summaryRow(
                      'Expected Cash in Drawer',
                      'Rs ${expectedCash.toStringAsFixed(0)}',
                      isBold: true,
                      highlightColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Actual Cash Counted input
              Text('Actual Cash Counted in Drawer *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.onSurface)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
                ),
                child: TextField(
                  controller: closingCashController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  onChanged: (val) {
                    setState(() {
                      countedCash = double.tryParse(val.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
                    });
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    prefixText: 'Rs ',
                    hintText: 'Enter counted amount',
                    prefixStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Variance indicator
              if (closingCashController.text.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: diff == 0
                        ? Colors.green.withValues(alpha: 0.15)
                        : (diff > 0 ? Colors.blue.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        diff == 0 ? Icons.check_circle : (diff > 0 ? Icons.arrow_upward : Icons.warning_rounded),
                        color: diff == 0 ? Colors.green : (diff > 0 ? Colors.blue : Colors.red),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        diff == 0
                            ? 'Balanced (Rs 0.00 difference)'
                            : (diff > 0
                                ? 'Cash Over: +Rs ${diff.toStringAsFixed(0)}'
                                : 'Cash Short: -Rs ${(-diff).toStringAsFixed(0)}'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: diff == 0 ? Colors.green : (diff > 0 ? Colors.blue : Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),

              // Shift Notes
              Text('Closing Notes / Remarks', style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
                ),
                child: TextField(
                  controller: notesController,
                  style: TextStyle(fontSize: 13, color: colors.onSurface),
                  decoration: InputDecoration(
                    hintText: 'e.g. End of shift, handed drawer to Evening Cashier',
                    hintStyle: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Bottom Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final amount = double.tryParse(closingCashController.text.trim()) ?? 0.0;
                      final success = await widget.controller.closeShift(amount, notes: notesController.text.trim());
                      if (success) {
                        Get.back();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.lock_rounded, size: 16, color: Colors.white),
                    label: const Text('Close & End Shift', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _summaryRow(String label, String value, {bool isBold = false, Color? highlightColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: highlightColor,
            ),
          ),
        ],
      ),
    );
  }
}
