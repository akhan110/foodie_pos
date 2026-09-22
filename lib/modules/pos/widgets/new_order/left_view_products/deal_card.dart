import 'package:flutter/material.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/app/widgets/app_image_widget.dart';
import 'package:foodiepos/app/widgets/custom_text_widget.dart';
import 'package:foodiepos/modules/deals/models/deal_model.dart';
import 'package:foodiepos/modules/pos/controllers/pos_controller.dart';
import 'package:get/get.dart';

class DealCard extends StatelessWidget {
  const DealCard({
    super.key,
    required this.deal,
  });

  final DealModel deal;

  _DealBadgeInfo _getBadgeInfo(DealModel deal) {
    final nameLower = deal.name.toLowerCase();
    final catLower = deal.category.toLowerCase();

    if (nameLower.contains('burger') || nameLower.contains('smash')) {
      return const _DealBadgeInfo(label: 'Best Seller', color: Color(0xFFEF4444));
    } else if (nameLower.contains('pizza') || catLower.contains('family')) {
      return const _DealBadgeInfo(label: 'Popular', color: Color(0xFF10B981));
    } else if (nameLower.contains('chicken') || catLower.contains('limited')) {
      return const _DealBadgeInfo(label: 'Limited Time', color: Color(0xFF8B5CF6));
    } else if (nameLower.contains('kid')) {
      return const _DealBadgeInfo(label: 'Kids Favorite', color: Color(0xFFF59E0B));
    } else if (nameLower.contains('couple') || deal.discountAmount >= 250) {
      return const _DealBadgeInfo(label: 'Save More', color: Color(0xFFEF4444));
    } else if (nameLower.contains('dessert') || nameLower.contains('sweet')) {
      return const _DealBadgeInfo(label: 'Sweet Deal', color: Color(0xFF0EA5E9));
    } else {
      return _DealBadgeInfo(
        label: deal.category.isNotEmpty ? deal.category : 'Special Deal',
        color: AppColors.primary,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final posController = Get.isRegistered<PosController>() ? Get.find<PosController>() : null;
    final badge = _getBadgeInfo(deal);

    // Formatted prices
    final normalPrice = deal.originalPrice > deal.price ? deal.originalPrice : (deal.price + deal.discountAmount);
    final savings = normalPrice > deal.price ? (normalPrice - deal.price) : deal.discountAmount;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2330) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (posController != null) {
              posController.addDealToCart(deal);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TOP: BADGE + IMAGE
                Expanded(
                  child: Stack(
                    children: [
                      // Deal Hero Image
                      Positioned.fill(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: AppImageWidget(
                              imagePath: deal.image,
                              fit: BoxFit.contain,
                              fallbackIconSize: 64,
                            ),
                          ),
                        ),
                      ),

                      // Badge Pill on Top Left
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: badge.color,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: badge.color.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            badge.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // DEAL TITLE
                CustomTextWidget(
                  deal.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: colors.onSurface,
                  ),
                ),

                const SizedBox(height: 3),

                // DEAL DESCRIPTION / INCLUDED ITEMS
                CustomTextWidget(
                  deal.description ??
                      (deal.items.isNotEmpty
                          ? deal.items.map((it) => '${it.quantity > 1 ? "${it.quantity} " : ""}${it.productName}').join(' + ')
                          : 'Delicious combo meal'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 10),

                // PRICING DETAILS & ADD BUTTON
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Prices stack
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Normal Price with Strikethrough
                          if (normalPrice > deal.price)
                            Row(
                              children: [
                                Text(
                                  'Normal Price  ',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Rs ${normalPrice.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                                    decoration: TextDecoration.lineThrough,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                          const SizedBox(height: 2),

                          // Deal Price
                          Row(
                            children: [
                              const Text(
                                'Deal Price  ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Rs ${deal.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 2),

                          // You Save
                          if (savings > 0)
                            Row(
                              children: [
                                const Text(
                                  'You Save  ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF10B981),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Rs ${savings.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF10B981),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // + Add Button
                    if (posController != null)
                      Obx(() {
                        final inCartQty = posController.getProductCartQuantity('deal-${deal.id}');

                        return Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => posController.addDealToCart(deal),
                              borderRadius: BorderRadius.circular(10),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.add, size: 16, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text(
                                      inCartQty > 0 ? 'Add ($inCartQty)' : 'Add',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DealBadgeInfo {
  final String label;
  final Color color;

  const _DealBadgeInfo({
    required this.label,
    required this.color,
  });
}
