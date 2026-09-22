import 'package:flutter/material.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:foodiepos/modules/dashboard/widgets/hourly_sales_chart.dart';
import 'package:foodiepos/modules/dashboard/widgets/kpi_card.dart';
import 'package:foodiepos/modules/dashboard/widgets/payment_breakdown_card.dart';
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
      backgroundColor: colors.surface,
      body: Obx(() {
        final data = controller.data.value;

        if (controller.isLoading.value && data == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final revenue = data?.totalRevenue ?? 0.0;
        final orders = data?.totalOrders ?? 0;
        final aov = data?.avgOrderValue ?? 0.0;
        final tax = data?.totalTax ?? 0.0;
        final discount = data?.totalDiscount ?? 0.0;
        final payments = data?.paymentBreakdown ?? {};
        final topItems = data?.topSellingItems ?? [];
        final hourlySales = data?.hourlySales ?? List.filled(24, 0.0);

        return RefreshIndicator(
          onRefresh: () => controller.fetchAnalytics(showSpinner: false),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. TOP HEADER & RANGE SELECTOR
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sales & Performance Dashboard',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Real-time overview of revenue, transactions, and store operations',
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),

                    // Time Range Selector & Refresh
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainer,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? const Color(0xFF2A313F) : theme.dividerColor,
                            ),
                          ),
                          child: Row(
                            children: ['Today', 'This Week', 'This Month'].map((range) {
                              final isSelected = controller.selectedTimeRange.value == range;
                              return InkWell(
                                onTap: () => controller.setTimeRange(range),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    range,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? Colors.white : colors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton.filledTonal(
                          onPressed: () => controller.fetchAnalytics(showSpinner: false),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          tooltip: 'Refresh Analytics',
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 2. 4 TOP KPI CARDS
                Row(
                  children: [
                    Expanded(
                      child: KpiCard(
                        title: 'Total Revenue',
                        value: 'Rs ${revenue.toStringAsFixed(0)}',
                        subtitle: 'Gross revenue today',
                        icon: Icons.payments_rounded,
                        accentColor: AppColors.primary,
                        badgeText: '+14.2%',
                        isPositive: true,
                      ),
                    ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: KpiCard(
                            title: 'Completed Orders',
                            value: '$orders orders',
                            subtitle: '100% fulfill rate',
                            icon: Icons.receipt_long_rounded,
                            accentColor: const Color(0xFF3B82F6),
                            badgeText: '+8.1%',
                            isPositive: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: KpiCard(
                            title: 'Avg Order Value',
                            value: 'Rs ${aov.toStringAsFixed(0)}',
                            subtitle: 'Per completed ticket',
                            icon: Icons.shopping_bag_rounded,
                            accentColor: const Color(0xFF10B981),
                            badgeText: '+4.5%',
                            isPositive: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: KpiCard(
                            title: 'Taxes & Discounts',
                            value: 'Rs ${tax.toStringAsFixed(0)}',
                            subtitle: 'Rs ${discount.toStringAsFixed(0)} in promo discounts',
                            icon: Icons.account_balance_wallet_rounded,
                            accentColor: const Color(0xFF8B5CF6),
                          ),
                        ),
                      ],
                    ),

                const SizedBox(height: 24),

                // 3. HOURLY SALES CHART
                HourlySalesChart(hourlySales: hourlySales),

                const SizedBox(height: 24),

                // 4. BOTTOM 2-COLUMN SECTION: TOP SELLING ITEMS & PAYMENT METHODS
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: TopSellingCard(items: topItems),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 4,
                      child: PaymentBreakdownCard(
                        paymentBreakdown: payments,
                        totalRevenue: revenue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
