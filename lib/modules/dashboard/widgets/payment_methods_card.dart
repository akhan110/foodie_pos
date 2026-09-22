import 'package:flutter/material.dart';
import 'package:foodiepos/app/theme/app_colors.dart';

class PaymentMethodsCard extends StatelessWidget {
  final Map<String, Map<String, dynamic>> paymentMethods;

  const PaymentMethodsCard({super.key, required this.paymentMethods});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;

    final colorMap = {
      'Cash': const Color(0xFF12B76A),
      'Card': const Color(0xFF2E90FA),
      'Mobile Payment': const Color(0xFF7A5AF8),
      'Other': const Color(0xFF98A2B3),
    };

    final iconBgMap = {
      'Cash': const Color(0xFFE8FDF2),
      'Card': const Color(0xFFEFF8FF),
      'Mobile Payment': const Color(0xFFF4F3FF),
      'Other': const Color(0xFFF2F4F7),
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
                    child: const Icon(Icons.credit_card_rounded, color: Color(0xFF2E90FA), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Methods',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Revenue distribution by payment method',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Text(
                'View Details',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Payment rows
          ...paymentMethods.entries.map((entry) {
            final key = entry.key;
            final data = entry.value;
            final pct = (data['pct'] as num?)?.toInt() ?? 0;
            final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
            final iconStr = data['icon']?.toString() ?? '💵';
            final barColor = colorMap[key] ?? const Color(0xFF12B76A);
            final iconBg = isDark ? const Color(0xFF252A36) : (iconBgMap[key] ?? const Color(0xFFF2F4F7));

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  // Icon box
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(iconStr, style: const TextStyle(fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Label
                  SizedBox(
                    width: 90,
                    child: Text(
                      key,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Progress Bar
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2A313F) : const Color(0xFFEAECF0),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: (pct / 100).clamp(0.02, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: barColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Percentage
                  SizedBox(
                    width: 34,
                    child: Text(
                      '$pct%',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Amount
                  SizedBox(
                    width: 60,
                    child: Text(
                      'Rs ${amount.toStringAsFixed(0)}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
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
}
