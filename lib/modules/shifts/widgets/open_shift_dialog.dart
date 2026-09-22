import 'package:flutter/material.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/modules/shifts/controllers/shift_controller.dart';
import 'package:get/get.dart';

class OpenShiftDialog extends StatefulWidget {
  final ShiftController controller;

  const OpenShiftDialog({super.key, required this.controller});

  static void show(BuildContext context, ShiftController controller) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440, maxHeight: 460),
          child: OpenShiftDialog(controller: controller),
        ),
      ),
    );
  }

  @override
  State<OpenShiftDialog> createState() => _OpenShiftDialogState();
}

class _OpenShiftDialogState extends State<OpenShiftDialog> {
  final TextEditingController floatController = TextEditingController(text: '5000');
  final TextEditingController notesController = TextEditingController();

  final List<double> presetFloats = [2000, 5000, 10000, 15000];

  @override
  void dispose() {
    floatController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.point_of_sale_rounded, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Open Cashier Shift',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Enter starting cash float in drawer',
                    style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Preset float pills
          Wrap(
            spacing: 8,
            children: presetFloats.map((val) {
              return ActionChip(
                label: Text('Rs ${val.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12)),
                onPressed: () {
                  setState(() {
                    floatController.text = val.toStringAsFixed(0);
                  });
                },
                backgroundColor: colors.surfaceContainer,
                side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Opening float input
          Text('Opening Float Amount (Rs) *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.onSurface)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
            ),
            child: TextField(
              controller: floatController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                border: InputBorder.none,
                prefixText: 'Rs ',
                prefixStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Notes
          Text('Shift Notes (Optional)', style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
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
                hintText: 'e.g. Morning Shift - Drawer 1',
                hintStyle: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 22),

          // Actions
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
                  final amount = double.tryParse(floatController.text.trim()) ?? 0.0;
                  final success = await widget.controller.openShift(amount, notes: notesController.text.trim());
                  if (success) {
                    Get.back();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.check, size: 16, color: Colors.white),
                label: const Text('Start Shift', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
