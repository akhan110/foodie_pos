import 'package:flutter/material.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/app/widgets/app_image_widget.dart';
import 'package:foodiepos/app/widgets/custom_text_widget.dart';
import 'package:foodiepos/modules/pos/model/cart_model.dart';

class CartItemTile extends StatefulWidget {
  const CartItemTile({
    super.key,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.quantity,
    required this.image,
    required this.onRemove,
    this.extras = const [],
    this.onDecrease,
    this.onIncrease,
  });

  final String name;
  final String subtitle;
  final double price;
  final int quantity;
  final String image;
  final List<ProductExtraItem> extras;
  final VoidCallback onRemove;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  State<CartItemTile> createState() => _CartItemTileState();
}

class _CartItemTileState extends State<CartItemTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ============================================================
          // TOP ROW: Image + Name/Subtitle + Remove Button
          // ============================================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PRODUCT IMAGE
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF222B3B)
                      : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(3),
                child: AppImageWidget(
                  imagePath: widget.image,
                  fit: BoxFit.contain,
                  borderRadius: BorderRadius.circular(6),
                  fallbackIconSize: 20,
                ),
              ),

              const SizedBox(width: 10),

              // PRODUCT NAME + SUBTITLE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextWidget(
                      widget.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    CustomTextWidget(
                      widget.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              // REMOVE BUTTON
              Tooltip(
                message: 'Remove item',
                child: InkWell(
                  onTap: widget.onRemove,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ============================================================
          // ADDONS DROPDOWN SECTION (IF ITEM HAS EXTRAS)
          // ============================================================
          if (widget.extras.isNotEmpty) ...[
            const SizedBox(height: 6),
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E2636)
                      : colors.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.tune,
                          size: 12,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${widget.extras.length} Add-on${widget.extras.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : colors.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 16,
                      color: colors.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),

            if (_isExpanded) ...[
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF18202E)
                      : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.extras.map((extra) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                extra.name,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '+ Rs ${extra.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.primary.withValues(alpha: 0.9)
                                  : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],

          const SizedBox(height: 8),

          // ============================================================
          // BOTTOM ROW: Quantity Controls + Price
          // ============================================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // QUANTITY STEPPER
              Container(
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: colors.outline),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _QuantityButton(
                      icon: Icons.remove,
                      onTap: widget.onDecrease ?? () {},
                    ),
                    SizedBox(
                      width: 26,
                      child: CustomTextWidget(
                        '${widget.quantity}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    _QuantityButton(
                      icon: Icons.add,
                      onTap: widget.onIncrease ?? () {},
                    ),
                  ],
                ),
              ),

              // PRICE
              CustomTextWidget(
                'Rs ${widget.price.toStringAsFixed(0)}',
                textAlign: TextAlign.right,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        child: Icon(icon, size: 15, color: colors.onSurface),
      ),
    );
  }
}
