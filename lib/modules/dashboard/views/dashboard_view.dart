import 'package:flutter/material.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:foodiepos/modules/dashboard/widgets/kpi_card.dart';
import 'package:foodiepos/modules/dashboard/widgets/order_types_donut_chart.dart';
import 'package:foodiepos/modules/dashboard/widgets/payment_methods_card.dart';
import 'package:foodiepos/modules/dashboard/widgets/recent_orders_card.dart';
import 'package:foodiepos/modules/dashboard/widgets/sales_overview_chart.dart';
import 'package:foodiepos/modules/dashboard/widgets/top_selling_card.dart';
import 'package:get/get.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DashboardController>()) {
      Get.put(DashboardController());
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF13171F) : const Color(0xFFF6F8FA),
      body: Obx(() {
        final data = controller.data.value;

        if (controller.isLoading.value && data == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final rev = data?.totalRevenue ?? 12480.0;
        final revChg = data?.revenueChange ?? '+14.2%';
        final ord = data?.completedOrders ?? 86;
        final ordChg = data?.ordersChange ?? '+8.1%';
        final aov = data?.avgOrderValue ?? 145.0;
        final aovChg = data?.aovChange ?? '+5.6%';
        final tax = data?.taxesAndDiscounts ?? 1210.0;
        final taxChg = data?.taxChange ?? '-3.4%';

        final hourly = data?.hourlyData ?? [];
        final orderTypes = data?.orderTypes ?? [];
        final topItems = data?.topSellingItems ?? [];
        final recent = data?.recentOrders ?? [];
        final payments = data?.paymentMethods ?? {};

        final compLabel = data?.comparisonLabel ?? 'vs. yesterday';

        return RefreshIndicator(
          onRefresh: () => controller.fetchAnalytics(showSpinner: false),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =============================================================
                // 1. GREETING HEADER & DATE / TIME CONTROLS
                // =============================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Greeting
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Good Morning, ${controller.cashierName}!',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: colors.onSurface,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text('👋', style: TextStyle(fontSize: 20)),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Obx(() {
                          final isMyShift = controller.selectedScope.value == 'My Shift';
                          return Text(
                            isMyShift
                                ? "Here's your personal shift performance for ${controller.cashierName}."
                                : "Here's what's happening across the entire store.",
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.onSurfaceVariant,
                            ),
                          );
                        }),
                      ],
                    ),

                    // Date Pill + Scope Toggle + Time Range Selector
                    Row(
                      children: [
                        // Scope pill container (My Shift vs Store Overview)
                        Obx(() {
                          return Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E222B) : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark ? const Color(0xFF2A313F) : const Color(0xFFEAECF0),
                              ),
                            ),
                            child: Row(
                              children: [
                                {'label': 'My Shift', 'icon': Icons.person_outline},
                                {'label': 'Store', 'icon': Icons.storefront_outlined},
                              ].map((item) {
                                final label = item['label'] as String;
                                final icon = item['icon'] as IconData;
                                final isSelected = controller.selectedScope.value == label;

                                return InkWell(
                                  onTap: () => controller.setScope(label),
                                  borderRadius: BorderRadius.circular(8),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFFFF6B35) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          icon,
                                          size: 13,
                                          color: isSelected ? Colors.white : colors.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          label,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                            color: isSelected ? Colors.white : colors.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }),
                        const SizedBox(width: 10),

                        // Date picker button pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E222B) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? const Color(0xFF2A313F) : const Color(0xFFEAECF0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.calendar_today_outlined, size: 14, color: colors.onSurfaceVariant),
                              const SizedBox(width: 8),
                              Text(
                                'Tue, 16 Sep 2025',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: colors.onSurface,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(Icons.keyboard_arrow_down, size: 14, color: colors.onSurfaceVariant),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Range pill container
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E222B) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? const Color(0xFF2A313F) : const Color(0xFFEAECF0),
                            ),
                          ),
                          child: Row(
                            children: ['Today', 'This Week', 'This Month'].map((range) {
                              final isSelected = controller.selectedTimeRange.value == range;

                              return InkWell(
                                onTap: () => controller.setTimeRange(range),
                                borderRadius: BorderRadius.circular(8),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFFFF6B35) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Text(
                                    range,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected ? Colors.white : colors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // =============================================================
                // 2. 4 TOP KPI CARDS
                // =============================================================
                Row(
                  children: [
                    Expanded(
                      child: KpiCard(
                        title: 'Total Revenue',
                        value: 'Rs ${_formatCurrency(rev)}',
                        badgeText: revChg,
                        isPositive: !revChg.startsWith('-'),
                        comparisonLabel: compLabel,
                        icon: Icons.bar_chart_rounded,
                        iconBgColor: const Color(0xFF12B76A),
                        barColor: const Color(0xFF12B76A),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: KpiCard(
                        title: 'Completed Orders',
                        value: '$ord',
                        badgeText: ordChg,
                        isPositive: !ordChg.startsWith('-'),
                        comparisonLabel: compLabel,
                        icon: Icons.shopping_cart_outlined,
                        iconBgColor: const Color(0xFF2E90FA),
                        barColor: const Color(0xFF2E90FA),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: KpiCard(
                        title: 'Avg Order Value',
                        value: 'Rs ${_formatCurrency(aov)}',
                        badgeText: aovChg,
                        isPositive: !aovChg.startsWith('-'),
                        comparisonLabel: compLabel,
                        icon: Icons.receipt_outlined,
                        iconBgColor: const Color(0xFFF79009),
                        barColor: const Color(0xFFF79009),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: KpiCard(
                        title: 'Taxes & Discounts',
                        value: 'Rs ${_formatCurrency(tax)}',
                        badgeText: taxChg,
                        isPositive: !taxChg.startsWith('-'),
                        comparisonLabel: compLabel,
                        icon: Icons.local_offer_outlined,
                        iconBgColor: const Color(0xFF7A5AF8),
                        barColor: const Color(0xFF7A5AF8),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // =============================================================
                // 3. MIDDLE ROW: SALES OVERVIEW (62%) + ORDER TYPES (38%)
                // =============================================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 62,
                      child: SalesOverviewChart(hourlyData: hourly),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 38,
                      child: OrderTypesDonutChart(
                        orderTypes: orderTypes,
                        totalOrders: ord,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // =============================================================
                // 4. BOTTOM ROW: TOP SELLING + RECENT ORDERS + PAYMENT METHODS
                // =============================================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Selling Items (30%)
                    Expanded(
                      flex: 30,
                      child: TopSellingCard(items: topItems),
                    ),
                    const SizedBox(width: 16),

                    // Recent Orders (42%)
                    Expanded(
                      flex: 42,
                      child: RecentOrdersCard(orders: recent),
                    ),
                    const SizedBox(width: 16),

                    // Payment Methods (28%)
                    Expanded(
                      flex: 28,
                      child: PaymentMethodsCard(paymentMethods: payments),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // =============================================================
                // 5. FOOTER
                // =============================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'BiteFlow POS  v1.0.0',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      'Built for a Tastier Tomorrow 🍔',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      }),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000) {
      final parts = amount.toStringAsFixed(0).split('');
      final buffer = StringBuffer();
      int count = 0;
      for (int i = parts.length - 1; i >= 0; i--) {
        if (count > 0 && count % 3 == 0) {
          buffer.write(',');
        }
        buffer.write(parts[i]);
        count++;
      }
      return buffer.toString().split('').reversed.join('');
    }
    return amount.toStringAsFixed(0);
  }
}
