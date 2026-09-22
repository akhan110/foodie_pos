import 'package:flutter/material.dart';

class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String badgeText;
  final bool isPositive;
  final IconData icon;
  final Color iconBgColor;
  final Color barColor;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.badgeText,
    required this.isPositive,
    required this.icon,
    required this.iconBgColor,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Icon + Metric info
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Box
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                ),
                const SizedBox(width: 14),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: colors.onSurface,
                          letterSpacing: -0.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Change Badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: isPositive
                                  ? const Color(0xFFE8FDF2)
                                  : const Color(0xFFFFECEB),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                  size: 14,
                                  color: isPositive ? const Color(0xFF12B76A) : const Color(0xFFF04438),
                                ),
                                Text(
                                  badgeText,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isPositive ? const Color(0xFF12B76A) : const Color(0xFFF04438),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'vs. yesterday',
                            style: TextStyle(
                              fontSize: 10,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Right: Decorative mini bar chart illustration
          SizedBox(
            width: 44,
            height: 38,
            child: CustomPaint(
              painter: _MiniBarChartPainter(color: barColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBarChartPainter extends CustomPainter {
  final Color color;

  _MiniBarChartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final heights = [0.4, 0.65, 0.9, 1.0];
    final barWidth = size.width / (heights.length * 2);
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < heights.length; i++) {
      final h = size.height * heights[i];
      final x = i * barWidth * 2 + barWidth / 2;
      final y = size.height - h;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, h),
        const Radius.circular(2),
      );

      final alpha = 0.25 + (i * 0.25);
      paint.color = color.withValues(alpha: alpha);
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
