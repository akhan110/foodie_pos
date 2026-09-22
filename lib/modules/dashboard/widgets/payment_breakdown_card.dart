import 'package:flutter/material.dart';
import 'package:foodiepos/app/theme/app_colors.dart';

class PaymentBreakdownCard extends StatelessWidget {
  final Map<String, double> paymentBreakdown;
  final double totalRevenue;

  const PaymentBreakdownCard({
    super.key,
    required this.paymentBreakdown,
    required this.totalRevenue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;

    final safeTotal = totalRevenue > 0 ? totalRevenue : 1.0;

    final methodColors = {
      'Cash': const Color(0xFF10B981),
      'Card': const Color(0xFF3B82F6),
      'QR Pay': const Color(0xFF8B5CF6),
      'Split': const Color(0xFFF59E0B),
    };

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
          Text(
            'Payment Methods',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Revenue distribution by tender type',
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 18),

          // Progress bar distribution
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 14,
              child: Row(
                children: paymentBreakdown.entries.map((entry) {
                  final pct = (entry.value / safeTotal).clamp(0.0, 1.0);
                  if (pct <= 0) return const SizedBox.shrink();
                  final col = methodColors[entry.key] ?? AppColors.primary;

                  return Expanded(
                    flex: (pct * 100).round(),
                    child: Container(color: col),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // List of methods
          ...paymentBreakdown.entries.map((entry) {
            final col = methodColors[entry.key] ?? AppColors.primary;
            final pct = ((entry.value / safeTotal) * 100).toStringAsFixed(1);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(color: col, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Rs ${entry.value.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: col.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$pct%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: col,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
