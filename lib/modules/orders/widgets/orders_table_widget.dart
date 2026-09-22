import 'package:flutter/material.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/app/widgets/custom_text_widget.dart';
import 'package:foodiepos/modules/orders/controllers/orders_controller.dart';
import 'package:foodiepos/modules/orders/models/order_model.dart';
import 'package:get/get.dart';

class OrdersTableWidget extends GetView<OrdersController> {
  const OrdersTableWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER ROW: TITLE & EXPORT CSV BUTTON
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextWidget(
                    'Orders / History',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  CustomTextWidget(
                    'Search and review past restaurant orders',
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: controller.exportCsv,
                icon: const Icon(Icons.download_rounded, size: 16),
                label: const CustomTextWidget(
                  'Export CSV',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.onSurface,
                  side: BorderSide(
                    color: isDark ? const Color(0xFF2D333F) : theme.dividerColor,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // FILTER BAR (DATE, TYPE, STATUS, SEARCH)
          _buildFilterBar(context),

          const SizedBox(height: 18),

          // ORDERS TABLE
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E222B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF2D333F) : theme.dividerColor,
                ),
              ),
              child: Obx(() {
                if (controller.isLoading.value && controller.orders.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (controller.filteredOrders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 48,
                          color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        CustomTextWidget(
                          'No orders found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        CustomTextWidget(
                          'Try adjusting your search or filter settings.',
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // TABLE HEADER ROW
                    _buildTableHeader(context),

                    Divider(
                      height: 1,
                      thickness: 1,
                      color: isDark
                          ? const Color(0xFF2D333F)
                          : theme.dividerColor,
                    ),

                    // TABLE BODY - SCROLLABLE WITHOUT PAGINATION
                    Expanded(
                      child: ListView.separated(
                        itemCount: controller.filteredOrders.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          thickness: 1,
                          color: isDark
                              ? const Color(0xFF262B36)
                              : theme.dividerColor.withValues(alpha: 0.5),
                        ),
                        itemBuilder: (context, index) {
                          final order = controller.filteredOrders[index];
                          return _buildTableRow(context, order);
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final filterBg = isDark
        ? const Color(0xFF1E222B)
        : const Color(0xFFF4F6F9);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            // DATE FILTER DROPDOWN
            Obx(
              () => _buildDropdownButton(
                context: context,
                value: controller.selectedDateFilter.value,
                items: controller.dateOptions,
                onChanged: controller.onDateFilterChanged,
                backgroundColor: filterBg,
                width: 140,
              ),
            ),

            const SizedBox(width: 12),

            // TYPE FILTER DROPDOWN
            Obx(
              () => _buildDropdownButton(
                context: context,
                value: controller.selectedTypeFilter.value,
                items: controller.typeOptions,
                onChanged: controller.onTypeFilterChanged,
                backgroundColor: filterBg,
                width: 150,
              ),
            ),

            const SizedBox(width: 12),

            // STATUS FILTER DROPDOWN
            Obx(
              () => _buildDropdownButton(
                context: context,
                value: controller.selectedStatusFilter.value,
                items: controller.statusOptions,
                onChanged: controller.onStatusFilterChanged,
                backgroundColor: filterBg,
                width: 150,
              ),
            ),

            const SizedBox(width: 12),

            // SEARCH BAR
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: filterBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF2D333F)
                        : theme.dividerColor.withValues(alpha: 0.6),
                  ),
                ),
                child: TextField(
                  controller: controller.searchController,
                  onChanged: controller.onSearchChanged,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    color: colors.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search order number...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 18,
                      color: colors.onSurfaceVariant,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDropdownButton({
    required BuildContext context,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    required Color backgroundColor,
    required double width,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 44,
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2D333F)
              : theme.dividerColor.withValues(alpha: 0.6),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          onChanged: onChanged,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: colors.onSurfaceVariant,
          ),
          dropdownColor: isDark ? const Color(0xFF1E222B) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          items: items.map((opt) {
            return DropdownMenuItem<String>(
              value: opt,
              child: CustomTextWidget(
                opt,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colors.onSurface,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(flex: 2, child: _headerCell('ORDER', colors)),
          Expanded(flex: 2, child: _headerCell('TIME', colors)),
          Expanded(flex: 2, child: _headerCell('TYPE', colors)),
          Expanded(flex: 1, child: _headerCell('ITEMS', colors)),
          Expanded(flex: 2, child: _headerCell('TOTAL', colors)),
          Expanded(flex: 2, child: _headerCell('STATUS', colors)),
          SizedBox(width: 60, child: _headerCell('ACTIONS', colors, align: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _headerCell(String title, ColorScheme colors, {TextAlign align = TextAlign.start}) {
    return CustomTextWidget(
      title,
      textAlign: align,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: colors.onSurfaceVariant.withValues(alpha: 0.7),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, OrderModel order) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () => controller.selectOrder(order),
      hoverColor: isDark
          ? Colors.white.withValues(alpha: 0.04)
          : Colors.black.withValues(alpha: 0.02),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // ORDER NUMBER
            Expanded(
              flex: 2,
              child: CustomTextWidget(
                order.orderNumber,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
            ),

            // TIME
            Expanded(
              flex: 2,
              child: CustomTextWidget(
                order.formattedTime,
                style: TextStyle(
                  fontSize: 13,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),

            // TYPE
            Expanded(
              flex: 2,
              child: CustomTextWidget(
                order.orderType,
                style: TextStyle(
                  fontSize: 13,
                  color: colors.onSurface,
                ),
              ),
            ),

            // ITEMS COUNT
            Expanded(
              flex: 1,
              child: CustomTextWidget(
                '${order.itemsCount}',
                style: TextStyle(
                  fontSize: 13,
                  color: colors.onSurface,
                ),
              ),
            ),

            // TOTAL
            Expanded(
              flex: 2,
              child: CustomTextWidget(
                order.formattedTotal,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
            ),

            // STATUS BADGE
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: order.statusBadgeBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CustomTextWidget(
                    order.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: order.statusBadgeTextColor,
                    ),
                  ),
                ),
              ),
            ),

            // ACTIONS
            SizedBox(
              width: 60,
              child: Align(
                alignment: Alignment.centerRight,
                child: PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    color: colors.onSurfaceVariant,
                    size: 20,
                  ),
                  color: isDark ? const Color(0xFF1E222B) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onSelected: (action) {
                    if (action == 'details') {
                      controller.selectOrder(order);
                    } else if (action == 'reprint') {
                      controller.reprintReceipt(order);
                    } else if (action == 'void') {
                      controller.voidOrder(order);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'details',
                      child: Row(
                        children: [
                          Icon(Icons.visibility_outlined, size: 16),
                          SizedBox(width: 8),
                          CustomTextWidget('View Details', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'reprint',
                      child: Row(
                        children: [
                          Icon(Icons.print_outlined, size: 16),
                          SizedBox(width: 8),
                          CustomTextWidget('Reprint Receipt', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    if (order.status.toLowerCase() != 'voided')
                      const PopupMenuItem(
                        value: 'void',
                        child: Row(
                          children: [
                            Icon(Icons.cancel_outlined, size: 16, color: AppColors.error),
                            SizedBox(width: 8),
                            CustomTextWidget(
                              'Void Order',
                              style: TextStyle(fontSize: 13, color: AppColors.error),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
