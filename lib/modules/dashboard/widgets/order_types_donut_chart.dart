import 'dart:math';
import 'package:flutter/material.dart';
import 'package:foodiepos/modules/dashboard/models/dashboard_model.dart';

class OrderTypesDonutChart extends StatelessWidget {
  final List<OrderTypeStatModel> orderTypes;
  final int totalOrders;

  const OrderTypesDonutChart({
    super.key,
    required this.orderTypes,
    required this.totalOrders,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;

    final colorMap = {
      'Dine In': const Color(0xFF12B76A),
      'Takeaway': const Color(0xFFF79009),
      'Delivery': const Color(0xFF2E90FA),
      'Drive Through': const Color(0xFF7A5AF8),
    };

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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7A5AF8).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.donut_large_rounded, color: Color(0xFF7A5AF8), size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Types',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Distribution of orders today',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Donut Chart + Legend side-by-side
          Row(
            children: [
              // Donut Graphic with center text
              SizedBox(
                width: 130,
                height: 130,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(130, 130),
                      painter: _DonutChartPainter(
                        orderTypes: orderTypes,
                        colorMap: colorMap,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$totalOrders',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Orders',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 24),

              // Legend Table
              Expanded(
                child: Column(
                  children: orderTypes.map((item) {
                    final color = colorMap[item.type] ?? const Color(0xFF12B76A);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.type,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colors.onSurface,
                              ),
                            ),
                          ),
                          Text(
                            '${item.percentage}%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 24,
                            child: Text(
                              '${item.count}',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: colors.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<OrderTypeStatModel> orderTypes;
  final Map<String, Color> colorMap;

  _DonutChartPainter({
    required this.orderTypes,
    required this.colorMap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 14.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final totalPct = orderTypes.fold<int>(0, (sum, i) => sum + i.percentage);
    final safeTotal = totalPct > 0 ? totalPct : 100;

    double startAngle = -pi / 2;
    const gapAngle = 0.08;

    for (final item in orderTypes) {
      final sweepAngle = (item.percentage / safeTotal) * 2 * pi - gapAngle;
      if (sweepAngle <= 0) continue;

      paint.color = colorMap[item.type] ?? const Color(0xFF12B76A);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
