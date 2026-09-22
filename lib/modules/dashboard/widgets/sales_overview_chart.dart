import 'package:flutter/material.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:foodiepos/modules/dashboard/models/dashboard_model.dart';
import 'package:get/get.dart';

class SalesOverviewChart extends GetView<DashboardController> {
  final List<HourlyDataPoint> hourlyData;

  const SalesOverviewChart({super.key, required this.hourlyData});

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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.bar_chart_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sales Overview',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Hourly revenue and order volume',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Legend & Dropdown
              Row(
                children: [
                  _legendDot(const Color(0xFFFF6B35), 'Revenue (Rs)'),
                  const SizedBox(width: 14),
                  _legendDot(const Color(0xFF3B82F6), 'Orders'),
                  const SizedBox(width: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF252A36) : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? const Color(0xFF2A313F) : const Color(0xFFD0D5DD),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Today',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down, size: 16, color: colors.onSurfaceVariant),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Chart Canvas & Tooltip Container
          SizedBox(
            height: 220,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;

                return Obx(() {
                  final hoveredIdx = controller.hoveredHourIndex.value;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Background grid lines & Y-axis labels
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _GridLinesPainter(isDark: isDark),
                        ),
                      ),

                      // Chart Painter (Bars + Blue Line + Dots)
                      Positioned(
                        left: 36,
                        right: 12,
                        top: 10,
                        bottom: 24,
                        child: GestureDetector(
                          onTapDown: (details) {
                            final localX = details.localPosition.dx;
                            final chartWidth = width - 48;
                            final itemWidth = chartWidth / hourlyData.length;
                            final idx = (localX / itemWidth).floor().clamp(0, hourlyData.length - 1);
                            controller.hoveredHourIndex.value = idx;
                          },
                          child: CustomPaint(
                            painter: _SalesChartPainter(
                              data: hourlyData,
                              selectedIndex: hoveredIdx,
                              isDark: isDark,
                            ),
                          ),
                        ),
                      ),

                      // Floating Interactive Tooltip
                      if (hoveredIdx >= 0 && hoveredIdx < hourlyData.length)
                        _buildFloatingTooltip(
                          hourlyData[hoveredIdx],
                          hoveredIdx,
                          width - 48,
                          height,
                          isDark,
                        ),

                      // X-Axis Hour Labels
                      Positioned(
                        left: 36,
                        right: 12,
                        bottom: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: hourlyData.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final point = entry.value;
                            final isHovered = hoveredIdx == idx;

                            return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              onEnter: (_) => controller.hoveredHourIndex.value = idx,
                              child: Text(
                                point.label,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isHovered ? FontWeight.bold : FontWeight.w500,
                                  color: isHovered ? AppColors.primary : const Color(0xFF98A2B3),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildFloatingTooltip(
    HourlyDataPoint point,
    int index,
    double chartWidth,
    double totalHeight,
    bool isDark,
  ) {
    final itemWidth = chartWidth / hourlyData.length;
    final centerX = 36 + (index * itemWidth) + (itemWidth / 2);
    final leftPos = (centerX - 68).clamp(10.0, chartWidth - 60);

    return Positioned(
      left: leftPos,
      top: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF252A36) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? const Color(0xFF3B4456) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              point.label == '12PM' ? '12:00 PM' : '${point.label}:00',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: Color(0xFFFF6B35), shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                const Text('Revenue  ', style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text(
                  'Rs ${point.revenue.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: Color(0xFF3B82F6), shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                const Text('Orders    ', style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text(
                  '${point.orders}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GridLinesPainter extends CustomPainter {
  final bool isDark;

  _GridLinesPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = isDark ? const Color(0xFF2A313F).withValues(alpha: 0.5) : const Color(0xFFF2F4F7)
      ..strokeWidth = 1;

    final textStyle = TextStyle(
      color: isDark ? const Color(0xFF667085) : const Color(0xFF98A2B3),
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );

    final labels = ['4K', '3K', '2K', '1K', '0'];
    final chartHeight = size.height - 30;

    for (int i = 0; i < labels.length; i++) {
      final y = 10 + (i * (chartHeight / (labels.length - 1)));

      // Draw dashed horizontal line
      canvas.drawLine(Offset(32, y), Offset(size.width, y), linePaint);

      // Y-axis text
      final textPainter = TextPainter(
        text: TextSpan(text: labels[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(canvas, Offset(24 - textPainter.width, y - 6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SalesChartPainter extends CustomPainter {
  final List<HourlyDataPoint> data;
  final int selectedIndex;
  final bool isDark;

  _SalesChartPainter({
    required this.data,
    required this.selectedIndex,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxRev = 4000.0;
    final maxOrders = 30.0;
    final count = data.length;
    final itemWidth = size.width / count;
    final barWidth = itemWidth * 0.55;

    // 1. Draw Bars (Revenue)
    for (int i = 0; i < count; i++) {
      final item = data[i];
      final isSelected = i == selectedIndex;
      final barHeight = (item.revenue / maxRev) * size.height;
      final x = (i * itemWidth) + (itemWidth - barWidth) / 2;
      final y = size.height - barHeight;

      final barRect = Rect.fromLTWH(x, y, barWidth, barHeight);
      final rrect = RRect.fromRectAndCorners(
        barRect,
        topLeft: const Radius.circular(5),
        topRight: const Radius.circular(5),
      );

      final barPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isSelected
              ? [
                  const Color(0xFFFF6B35),
                  const Color(0xFFFF8C5A),
                ]
              : [
                  const Color(0xFFFFB692),
                  const Color(0xFFFFE0D0).withValues(alpha: isDark ? 0.4 : 0.7),
                ],
        ).createShader(barRect);

      canvas.drawRRect(rrect, barPaint);
    }

    // 2. Draw Smooth Blue Line & Points (Orders)
    final linePath = Path();
    final points = <Offset>[];

    for (int i = 0; i < count; i++) {
      final item = data[i];
      final x = (i * itemWidth) + (itemWidth / 2);
      final y = size.height - ((item.orders / maxOrders) * size.height).clamp(0.0, size.height);
      points.add(Offset(x, y));

      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        final prev = points[i - 1];
        final midX = (prev.dx + x) / 2;
        linePath.cubicTo(midX, prev.dy, midX, y, x, y);
      }
    }

    final linePaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(linePath, linePaint);

    // Draw Points
    final dotFillPaint = Paint()..color = const Color(0xFF3B82F6);
    final dotWhiteBorder = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      final isSelected = i == selectedIndex;

      canvas.drawCircle(pt, isSelected ? 5.5 : 4, dotFillPaint);
      canvas.drawCircle(pt, isSelected ? 5.5 : 4, dotWhiteBorder);
    }
  }

  @override
  bool shouldRepaint(covariant _SalesChartPainter oldDelegate) =>
      oldDelegate.selectedIndex != selectedIndex || oldDelegate.data != data;
}
