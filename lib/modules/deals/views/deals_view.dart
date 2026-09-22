import 'package:flutter/material.dart';
import 'package:foodiepos/modules/deals/controllers/deals_controller.dart';
import 'package:foodiepos/modules/deals/widgets/deal_editor_section.dart';
import 'package:foodiepos/modules/deals/widgets/deals_list_section.dart';
import 'package:get/get.dart';

class DealsView extends GetView<DealsController> {
  const DealsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is registered
    if (!Get.isRegistered<DealsController>()) {
      Get.put(DealsController());
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF13171F) : const Color(0xFFF6F8FA),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================================================================
            // 1. TOP HEADER & CREATE DEAL BUTTON
            // =================================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title + Subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deals Management',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: colors.onSurface,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Create and manage combo deals, meal offers and promotions.',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                // + Create Deal Button
                ElevatedButton.icon(
                  onPressed: () => controller.startNewDeal(),
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: const Text(
                    'Create Deal',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // =================================================================
            // 2. TWO-PANEL SPLIT: LIST (52%) + EDITOR (48%)
            // =================================================================
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Expanded(
                    flex: 52,
                    child: DealsListSection(),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    flex: 48,
                    child: DealEditorSection(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
