import 'package:flutter/material.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/modules/dashboard/models/dashboard_model.dart';
import 'package:foodiepos/modules/shell/controller/main_shell_controller.dart';
import 'package:get/get.dart';

class RecentOrdersCard extends StatelessWidget {
  final List<RecentOrderRowModel> orders;

  const RecentOrdersCard({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E222B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A313F) : const Color(0xFFEAECF0),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E90FA).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.access_time_rounded, color: Color(0xFF2E90FA), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Orders',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Latest orders from today',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  if (Get.isRegistered<MainShellController>()) {
                    Get.find<MainShellController>().changePage(2);
                  }
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Table Header
          Row(
            children: [
              _colHeader('#', 44, colors),
              _colHeader('Time', 68, colors),
              _colHeader('Type', 82, colors),
              _colHeader('Items', 42, colors),
              _colHeader('Total', 72, colors),
              Expanded(child: _colHeader('Status', 70, colors, alignRight: true)),
            ],
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: isDark ? const Color(0xFF2A313F) : const Color(0xFFEAECF0)),
          const SizedBox(height: 6),

          // Rows
          ...orders.map((order) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  // Order #
                  SizedBox(
                    width: 44,
                    child: Text(
                      order.orderNumber,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                  ),

                  // Time
                  SizedBox(
                    width: 68,
                    child: Text(
                      order.time,
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),

                  // Type Pill
                  SizedBox(
                    width: 82,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _buildTypePill(order.orderType),
                    ),
                  ),

                  // Items Count
                  SizedBox(
                    width: 42,
                    child: Text(
                      '${order.itemsCount}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                  ),

                  // Total
                  SizedBox(
                    width: 72,
                    child: Text(
                      'Rs ${order.total.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                  ),

                  // Status Pill
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _buildStatusPill(order.status),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _colHeader(String label, double width, ColorScheme colors, {bool alignRight = false}) {
    return SizedBox(
      width: width,
      child: Text(
        label,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildTypePill(String type) {
    Color bg;
    Color fg;
    IconData icon;

    if (type.toLowerCase().contains('dine')) {
      bg = const Color(0xFFE8FDF2);
      fg = const Color(0xFF12B76A);
      icon = Icons.restaurant;
    } else if (type.toLowerCase().contains('take')) {
      bg = const Color(0xFFFEF0C7);
      fg = const Color(0xFFDC6803);
      icon = Icons.shopping_bag_outlined;
    } else {
      bg = const Color(0xFFEFF8FF);
      fg = const Color(0xFF175CD3);
      icon = Icons.delivery_dining;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: fg),
          const SizedBox(width: 3),
          Text(
            type,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String status) {
    final isCompleted = status.toLowerCase() == 'completed';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFE8FDF2) : const Color(0xFFEFF8FF),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.check : Icons.hourglass_top,
            size: 10,
            color: isCompleted ? const Color(0xFF12B76A) : const Color(0xFF175CD3),
          ),
          const SizedBox(width: 3),
          Text(
            status,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isCompleted ? const Color(0xFF12B76A) : const Color(0xFF175CD3),
            ),
          ),
        ],
      ),
    );
  }
}
