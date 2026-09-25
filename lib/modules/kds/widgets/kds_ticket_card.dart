import 'package:flutter/material.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/app/widgets/custom_text_widget.dart';
import 'package:foodiepos/modules/kds/controllers/kds_controller.dart';
import 'package:foodiepos/modules/orders/models/order_model.dart';
import 'package:get/get.dart';

class KdsTicketCard extends StatelessWidget {
  final OrderModel order;
  final KdsController controller;

  const KdsTicketCard({
    super.key,
    required this.order,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final statusLower = order.status.toLowerCase().trim();
    final isNew = statusLower == 'new' || statusLower == 'pending';
    final isPreparing = statusLower == 'preparing';
    final isReady = statusLower == 'ready';

    // Accent theme color per stage
    final Color stageColor;
    if (isNew) {
      stageColor = const Color(0xFFEF4444); // Red
    } else if (isPreparing) {
      stageColor = const Color(0xFFF59E0B); // Amber / Orange
    } else {
      stageColor = const Color(0xFF10B981); // Green
    }

    // Elapsed minutes
    final elapsedMinutes = DateTime.now().difference(order.createdAt).inMinutes.clamp(0, 999);
    final timeFormatted = order.formattedTime;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E222B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2C3240) : const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left color-coded accent bar
              Container(
                width: 6,
                color: stageColor,
              ),

              // Main ticket card content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // TOP HEADER ROW
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Order Number & Order Type & Table
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CustomTextWidget(
                                      order.orderNumber,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: colors.onSurface,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildOrderTypeBadge(context, order.orderType),
                                  ],
                                ),
                                if (order.tableNumber != null &&
                                    order.tableNumber!.trim().isNotEmpty &&
                                    !order.tableNumber!.toLowerCase().contains('counter')) ...[
                                  const SizedBox(height: 3),
                                  CustomTextWidget(
                                    order.tableNumber!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Elapsed timer & creation time
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomTextWidget(
                                    isReady ? 'Ready' : '$elapsedMinutes min',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: stageColor,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  PopupMenuButton<String>(
                                    icon: Icon(
                                      Icons.more_vert,
                                      size: 18,
                                      color: colors.onSurfaceVariant,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onSelected: (action) {
                                      if (controller.updatingOrderIds.contains(order.id)) return;
                                      if (action == 'new') controller.fetchOrders();
                                      if (action == 'preparing') controller.startCooking(order);
                                      if (action == 'ready') controller.markReady(order);
                                      if (action == 'served') controller.markServed(order);
                                    },
                                    itemBuilder: (context) => [
                                      if (!isPreparing)
                                        const PopupMenuItem(
                                          value: 'preparing',
                                          child: Text('Move to Preparing'),
                                        ),
                                      if (!isReady)
                                        const PopupMenuItem(
                                          value: 'ready',
                                          child: Text('Move to Ready'),
                                        ),
                                      const PopupMenuItem(
                                        value: 'served',
                                        child: Text('Mark Served'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              CustomTextWidget(
                                timeFormatted,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.5)),
                      const SizedBox(height: 10),

                      // ITEMS LIST
                      ...order.items.map((item) {
                        final sizeText = item.size != 'Regular' ? item.size : null;
                        final addonsText = (item.addons != null && item.addons!.isNotEmpty) ? item.addons : null;
                        final detailsList = [
                          if (sizeText != null && sizeText.isNotEmpty) sizeText,
                          if (addonsText != null && addonsText.isNotEmpty) addonsText,
                        ];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextWidget(
                                    '${item.quantity}  ×  ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                  Expanded(
                                    child: CustomTextWidget(
                                      item.productName,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: colors.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (detailsList.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 28, top: 1),
                                  child: CustomTextWidget(
                                    detailsList.join(' • '),
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 8),

                      // PREPARING PROGRESS BAR (Only for Preparing stage)
                      if (isPreparing) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: (elapsedMinutes / 12.0).clamp(0.1, 1.0),
                                  backgroundColor: colors.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation<Color>(stageColor),
                                  minHeight: 8,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            CustomTextWidget(
                              '$elapsedMinutes / 12 min',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],

                      // STAGE ACTION BUTTON
                      Obx(() {
                        final isUpdating = controller.updatingOrderIds.contains(order.id);

                        if (isNew) {
                          return SizedBox(
                            width: double.infinity,
                            height: 38,
                            child: ElevatedButton.icon(
                              onPressed: isUpdating ? null : () => controller.startCooking(order),
                              icon: isUpdating
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.play_arrow_rounded, size: 18, color: Colors.white),
                              label: Text(
                                isUpdating ? 'Starting...' : 'Start Cooking',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: stageColor,
                                disabledBackgroundColor: stageColor.withValues(alpha: 0.6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                              ),
                            ),
                          );
                        } else if (isPreparing) {
                          return Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 38,
                                  child: OutlinedButton.icon(
                                    onPressed: isUpdating ? null : () => controller.markReady(order),
                                    icon: isUpdating
                                        ? SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: stageColor),
                                          )
                                        : Icon(Icons.check_circle_outline, size: 16, color: stageColor),
                                    label: Text(
                                      isUpdating ? 'Updating...' : 'Ready',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: isUpdating ? stageColor.withValues(alpha: 0.6) : stageColor,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: isUpdating ? stageColor.withValues(alpha: 0.4) : stageColor,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else if (isReady) {
                          return SizedBox(
                            width: double.infinity,
                            height: 38,
                            child: ElevatedButton.icon(
                              onPressed: isUpdating ? null : () => controller.markServed(order),
                              icon: isUpdating
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.check_rounded, size: 18, color: Colors.white),
                              label: Text(
                                isUpdating ? 'Serving...' : 'Mark Served',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: stageColor,
                                disabledBackgroundColor: stageColor.withValues(alpha: 0.6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderTypeBadge(BuildContext context, String type) {
    final typeLower = type.toLowerCase();
    IconData icon = Icons.restaurant;
    Color color = AppColors.primary;

    if (typeLower.contains('takeaway')) {
      icon = Icons.shopping_bag_outlined;
      color = const Color(0xFF6366F1);
    } else if (typeLower.contains('delivery')) {
      icon = Icons.delivery_dining;
      color = const Color(0xFF0EA5E9);
    } else if (typeLower.contains('drive')) {
      icon = Icons.directions_car;
      color = const Color(0xFF8B5CF6);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            type,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
