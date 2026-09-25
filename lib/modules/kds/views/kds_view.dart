import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/app/theme/theme_controller.dart';
import 'package:foodiepos/app/widgets/custom_text_widget.dart';
import 'package:foodiepos/modules/kds/controllers/kds_controller.dart';
import 'package:foodiepos/modules/kds/widgets/kds_ticket_card.dart';
import 'package:foodiepos/modules/orders/models/order_model.dart';
import 'package:foodiepos/modules/shell/controllers/connectivity_controller.dart';
import 'package:get/get.dart';

class KdsView extends GetView<KdsController> {
  const KdsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF13171F) : const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            // =================================================================
            // TOP HEADER BAR
            // =================================================================
            _buildTopBar(context, theme, colors, isDark),

            // =================================================================
            // KANBAN COLUMNS (3 COLUMNS)
            // =================================================================
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.orders.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final newOrders = controller.newOrders;
                final preparingOrders = controller.preparingOrders;
                final readyOrders = controller.readyOrders;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. NEW ORDERS COLUMN (RED)
                      Expanded(
                        child: _buildKanbanColumn(
                          context: context,
                          title: 'New Orders',
                          count: newOrders.length,
                          headerBg: isDark ? const Color(0xFF3B1E22) : const Color(0xFFFFECEF),
                          accentColor: const Color(0xFFEF4444),
                          icon: Icons.receipt_long_rounded,
                          orders: newOrders,
                          emptyMessage: 'No new orders waiting',
                        ),
                      ),
                      const SizedBox(width: 14),

                      // 2. PREPARING COLUMN (AMBER/ORANGE)
                      Expanded(
                        child: _buildKanbanColumn(
                          context: context,
                          title: 'Preparing',
                          count: preparingOrders.length,
                          headerBg: isDark ? const Color(0xFF382916) : const Color(0xFFFFF4DE),
                          accentColor: const Color(0xFFF59E0B),
                          icon: Icons.outdoor_grill_rounded,
                          orders: preparingOrders,
                          emptyMessage: 'No orders currently cooking',
                        ),
                      ),
                      const SizedBox(width: 14),

                      // 3. READY COLUMN (GREEN)
                      Expanded(
                        child: _buildKanbanColumn(
                          context: context,
                          title: 'Ready',
                          count: readyOrders.length,
                          headerBg: isDark ? const Color(0xFF163226) : const Color(0xFFE8F8EE),
                          accentColor: const Color(0xFF10B981),
                          icon: Icons.check_circle_rounded,
                          orders: readyOrders,
                          emptyMessage: 'No ready orders',
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // TOP BAR
  // ===========================================================================

  Widget _buildTopBar(BuildContext context, ThemeData theme, ColorScheme colors, bool isDark) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E222B) : Colors.white,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          // BRANDING: LOGO + SUBTITLE
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: SvgPicture.asset(
                  'assets/svg/products/burger.svg',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'BiteFlow ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                      children: [
                        TextSpan(
                          text: 'POS',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'KITCHEN DISPLAY SYSTEM',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(width: 20),

          // FILTER CHIPS (All, Dine In, Takeaway, Delivery, Drive Thru)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(() {
                return Row(
                  children: [
                    _buildFilterChip('All', Icons.shopping_cart_outlined, controller.allCount),
                    const SizedBox(width: 8),
                    _buildFilterChip('Dine In', Icons.restaurant, controller.dineInCount),
                    const SizedBox(width: 8),
                    _buildFilterChip('Takeaway', Icons.shopping_bag_outlined, controller.takeawayCount),
                    const SizedBox(width: 8),
                    _buildFilterChip('Delivery', Icons.delivery_dining, controller.deliveryCount),
                    const SizedBox(width: 8),
                    _buildFilterChip('Drive Thru', Icons.directions_car, controller.driveThruCount),
                  ],
                );
              }),
            ),
          ),

          const SizedBox(width: 14),

          // CONNECTIVITY STATUS BADGE
          _buildOnlineBadge(context),

          const SizedBox(width: 14),

          // LIVE REAL-TIME CLOCK
          Obx(
            () => CustomTextWidget(
              controller.currentTime.value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // SOUND MUTE TOGGLE
          Obx(
            () => IconButton(
              tooltip: controller.isSoundMuted.value ? 'Unmute alerts' : 'Mute alerts',
              onPressed: controller.toggleSound,
              icon: Icon(
                controller.isSoundMuted.value ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                color: controller.isSoundMuted.value ? Colors.grey : AppColors.primary,
                size: 20,
              ),
            ),
          ),

          // THEME TOGGLE
          IconButton(
            tooltip: 'Toggle Theme',
            onPressed: () {
              if (Get.isRegistered<ThemeController>()) {
                Get.find<ThemeController>().toggleTheme();
              }
            },
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 20,
            ),
          ),

          // EXIT KDS
          IconButton(
            tooltip: 'Exit KDS Mode',
            onPressed: () => _confirmExitKds(context),
            icon: const Icon(Icons.logout_rounded, size: 20, color: AppColors.error),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, int count) {
    final isSelected = controller.selectedTypeFilter.value == label;

    return InkWell(
      onTap: () => controller.setTypeFilter(label),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? (label == 'All' ? AppColors.primary : AppColors.primary.withValues(alpha: 0.15))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.withValues(alpha: 0.3),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected && label == 'All' ? Colors.white : (isSelected ? AppColors.primary : Colors.grey),
            ),
            const SizedBox(width: 6),
            Text(
              '$label ($count)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected && label == 'All' ? Colors.white : (isSelected ? AppColors.primary : Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnlineBadge(BuildContext context) {
    final isOnline = Get.isRegistered<ConnectivityController>()
        ? Get.find<ConnectivityController>().isOnline.value
        : true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOnline ? AppColors.successSurface : AppColors.errorSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(width: 5),
          CustomTextWidget(
            isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isOnline ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // KANBAN COLUMN
  // ===========================================================================

  Widget _buildKanbanColumn({
    required BuildContext context,
    required String title,
    required int count,
    required Color headerBg,
    required Color accentColor,
    required IconData icon,
    required List<OrderModel> orders,
    required String emptyMessage,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF191D26) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          // COLUMN HEADER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: headerBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: accentColor),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomTextWidget(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: accentColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // TICKET CARDS LIST
          Expanded(
            child: orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 40, color: Colors.grey.withValues(alpha: 0.4)),
                        const SizedBox(height: 8),
                        Text(
                          emptyMessage,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      return KdsTicketCard(
                        key: ValueKey(orders[index].id),
                        order: orders[index],
                        controller: controller,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _confirmExitKds(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Exit Kitchen Display?'),
        content: const Text('Return to login screen or POS cashier counter?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.exitKds();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Exit to Login', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
