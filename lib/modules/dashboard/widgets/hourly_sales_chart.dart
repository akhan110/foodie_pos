import 'package:flutter/material.dart';
import 'package:foodiepos/app/theme/app_colors.dart';

class HourlySalesChart extends StatefulWidget {
  final List<double> hourlySales;

  const HourlySalesChart({super.key, required this.hourlySales});

  @override
  State<HourlySalesChart> createState() => _HourlySalesChartState();
}

class _HourlySalesChartState extends State<HourlySalesChart> {
  int? hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;

    final sales = widget.hourlySales.length == 24 ? widget.hourlySales : List.filled(24, 0.0);
    final maxSale = sales.fold(0.0, (max, val) => val > max ? val : max);
    final safeMax = maxSale > 0 ? maxSale : 1.0;

    // Filter to active restaurant operating hours (8 AM to 11 PM -> 16 hours)
    final operatingHours = List.generate(16, (i) => i + 8); // 8:00 to 23:00

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E222B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A313F) : theme.dividerColor.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hourly Sales Activity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Today\'s revenue trends by hour of day',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (hoveredIndex != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_formatHour(hoveredIndex!)}: Rs ${sales[hoveredIndex!].toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Chart Bars Area
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: operatingHours.map((hour) {
                final amount = sales[hour];
                final heightFactor = (amount / safeMax).clamp(0.04, 1.0);
                final isHovered = hoveredIndex == hour;
                final isPeak = amount == maxSale && maxSale > 0;

                return Expanded(
                  child: MouseRegion(
                    onEnter: (_) => setState(() => hoveredIndex = hour),
                    onExit: (_) => setState(() => hoveredIndex = null),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Bar
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                                height: 140 * heightFactor,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: isPeak
                                        ? [
                                            AppColors.primary,
                                            const Color(0xFFFF9248),
                                          ]
                                        : (isHovered
                                            ? [
                                                AppColors.primary.withValues(alpha: 0.9),
                                                AppColors.primary.withValues(alpha: 0.5),
                                              ]
                                            : [
                                                isDark
                                                    ? const Color(0xFF3B4456)
                                                    : const Color(0xFFCBD5E1),
                                                isDark
                                                    ? const Color(0xFF262D3B)
                                                    : const Color(0xFFE2E8F0),
                                              ]),
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: isPeak
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(alpha: 0.35),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : null,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Hour Label
                          Text(
                            _formatHourLabel(hour),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: isPeak || isHovered ? FontWeight.bold : FontWeight.normal,
                              color: isPeak ? AppColors.primary : colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _formatHour(int h) {
    if (h == 0) return '12:00 AM';
    if (h < 12) return '$h:00 AM';
    if (h == 12) return '12:00 PM';
    return '${h - 12}:00 PM';
  }

  String _formatHourLabel(int h) {
    if (h == 12) return '12P';
    if (h < 12) return '${h}A';
    return '${h - 12}P';
  }
}
