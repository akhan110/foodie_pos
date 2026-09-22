import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/app/widgets/custom_text_widget.dart';
import 'package:foodiepos/modules/pos/controllers/pos_controller.dart';
import 'package:foodiepos/modules/pos/model/cart_model.dart';
import 'package:foodiepos/modules/pos/model/product_model.dart';
import 'package:get/get.dart';

class ProductCustomizationDialog extends StatefulWidget {
  const ProductCustomizationDialog({super.key, required this.product});

  final ProductModel product;

  static Future<void> show(BuildContext context, ProductModel product) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ProductCustomizationDialog(product: product),
    );
  }

  @override
  State<ProductCustomizationDialog> createState() =>
      _ProductCustomizationDialogState();
}

class _ProductCustomizationDialogState
    extends State<ProductCustomizationDialog> {
  late List<ProductSizeOption> _sizes;
  late List<ProductExtraItem> _availableExtras;

  late ProductSizeOption _selectedSize;
  final Set<ProductExtraItem> _selectedExtras = {};
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _initCustomizationOptions();
  }

  void _initCustomizationOptions() {
    final cat = widget.product.category.name.toLowerCase();

    if (cat.contains('drink')) {
      _sizes = const [
        ProductSizeOption(id: 'regular', name: 'Regular', extraPrice: 0.0),
        ProductSizeOption(id: 'large', name: 'Large', extraPrice: 60.0),
        ProductSizeOption(id: 'xl', name: 'Jumbo', extraPrice: 110.0),
      ];
      _availableExtras = const [
        ProductExtraItem(id: 'ice', name: 'Extra ice', price: 0.0),
        ProductExtraItem(id: 'lemon', name: 'Lemon slice', price: 20.0),
        ProductExtraItem(id: 'mint', name: 'Fresh mint', price: 30.0),
        ProductExtraItem(id: 'syrup', name: 'Flavored syrup', price: 50.0),
      ];
    } else if (cat.contains('pizza')) {
      _sizes = const [
        ProductSizeOption(id: 'regular', name: 'Regular', extraPrice: 0.0),
        ProductSizeOption(id: 'large', name: 'Medium', extraPrice: 220.0),
        ProductSizeOption(id: 'xl', name: 'Large', extraPrice: 420.0),
      ];
      _availableExtras = const [
        ProductExtraItem(id: 'extra_cheese', name: 'Extra cheese', price: 120.0),
        ProductExtraItem(id: 'jalapenos', name: 'Jalapeños', price: 60.0),
        ProductExtraItem(id: 'mushrooms', name: 'Fresh mushrooms', price: 80.0),
        ProductExtraItem(id: 'stuffed_crust', name: 'Stuffed crust', price: 180.0),
      ];
    } else {
      // Default (Burgers, Chicken, Sides, Combos)
      _sizes = const [
        ProductSizeOption(id: 'regular', name: 'Regular', extraPrice: 0.0),
        ProductSizeOption(id: 'large', name: 'Large', extraPrice: 120.0),
        ProductSizeOption(id: 'xl', name: 'XL', extraPrice: 220.0),
      ];
      _availableExtras = const [
        ProductExtraItem(id: 'extra_cheese', name: 'Extra cheese', price: 90.0),
        ProductExtraItem(id: 'jalapenos', name: 'Jalapeños', price: 60.0),
        ProductExtraItem(id: 'extra_patty', name: 'Extra patty', price: 220.0),
        ProductExtraItem(id: 'special_sauce', name: 'Special sauce', price: 50.0),
      ];
    }

    _selectedSize = _sizes.first;
  }

  double get _calculatedUnitPrice =>
      widget.product.price +
      _selectedSize.extraPrice +
      _selectedExtras.fold(0.0, (sum, e) => sum + e.price);

  double get _calculatedTotalPrice => _calculatedUnitPrice * _quantity;

  String get _productDescription {
    final cat = widget.product.category.name.toLowerCase();
    if (cat.contains('burger')) {
      return 'Double-seared beef, cheese, lettuce and BiteFlow sauce.';
    } else if (cat.contains('pizza')) {
      return 'Crispy hand-stretched crust topped with rich mozzarella & herbs.';
    } else if (cat.contains('drink')) {
      return 'Chilled refreshing beverage served over ice.';
    } else if (cat.contains('side')) {
      return 'Freshly fried crispy golden side with custom seasoning.';
    }
    return 'Delicious fresh menu item prepared with quality ingredients.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E2430) : Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 680,
          maxHeight: 520,
        ),
        child: Stack(
          children: [
            // CLOSE BUTTON TOP RIGHT
            Positioned(
              top: 14,
              right: 14,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.close,
                    size: 20,
                    color: colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),

            // MAIN CONTENT ROW
            Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ==========================================
                  // LEFT COLUMN: Image & Description Card
                  // ==========================================
                  SizedBox(
                    width: 230,
                    child: Column(
                      children: [
                        // GRAPHIC BOX
                        Expanded(
                          flex: 3,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF262D3D)
                                  : const Color(0xFFFBF6F0),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: SvgPicture.asset(
                              widget.product.image,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(Icons.fastfood, size: 60, color: AppColors.primary),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // INFO CARD
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomTextWidget(
                                widget.product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: colors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              CustomTextWidget(
                                _productDescription,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: colors.onSurfaceVariant,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 22),

                  // ==========================================
                  // RIGHT COLUMN: Options, Extras, Controls
                  // ==========================================
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // PRODUCT NAME & BASE PRICE
                        Padding(
                          padding: const EdgeInsets.only(right: 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextWidget(
                                widget.product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 21,
                                  color: colors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              CustomTextWidget(
                                'Rs ${widget.product.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // SECTION 1: CHOOSE SIZE
                        CustomTextWidget(
                          'CHOOSE SIZE',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            letterSpacing: 0.6,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // SIZE PILLS
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _sizes.map((sizeOption) {
                            final isSelected = _selectedSize.id == sizeOption.id;
                            final priceText = sizeOption.extraPrice == 0
                                ? 'Rs ${widget.product.price.toStringAsFixed(0)}'
                                : '+ Rs ${sizeOption.extraPrice.toStringAsFixed(0)}';

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedSize = sizeOption;
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark
                                          ? const Color(0xFF262D3D)
                                          : const Color(0xFFF3F4F6)),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : theme.dividerColor.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Text(
                                  '${sizeOption.name} · $priceText',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : colors.onSurface,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 14),

                        // SECTION 2: ADD EXTRAS
                        CustomTextWidget(
                          'ADD EXTRAS',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            letterSpacing: 0.6,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // EXTRAS CARD
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: colors.surfaceContainer,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: theme.dividerColor.withValues(alpha: 0.6),
                              ),
                            ),
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              physics: const ClampingScrollPhysics(),
                              itemCount: _availableExtras.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                thickness: 1,
                                color: theme.dividerColor.withValues(alpha: 0.4),
                              ),
                              itemBuilder: (context, index) {
                                final extra = _availableExtras[index];
                                final isChecked = _selectedExtras.contains(extra);

                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (isChecked) {
                                        _selectedExtras.remove(extra);
                                      } else {
                                        _selectedExtras.add(extra);
                                      }
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        // CHECKBOX
                                        Container(
                                          width: 18,
                                          height: 18,
                                          decoration: BoxDecoration(
                                            color: isChecked
                                                ? AppColors.primary
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(
                                              color: isChecked
                                                  ? AppColors.primary
                                                  : colors.outline,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: isChecked
                                              ? const Icon(
                                                  Icons.check,
                                                  size: 13,
                                                  color: Colors.white,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 10),

                                        // EXTRA NAME
                                        Expanded(
                                          child: Text(
                                            extra.name,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontSize: 13,
                                              fontWeight: isChecked
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                              color: colors.onSurface,
                                            ),
                                          ),
                                        ),

                                        // PRICE
                                        Text(
                                          '+ Rs ${extra.price.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: isChecked
                                                ? AppColors.primary
                                                : colors.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // SECTION 3: BOTTOM ACTIONS (STEPPER + ADD TO ORDER BUTTON)
                        Row(
                          children: [
                            // QUANTITY STEPPER
                            Container(
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: theme.dividerColor.withValues(alpha: 0.6),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 16),
                                    splashRadius: 18,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 36,
                                    ),
                                    onPressed: _quantity > 1
                                        ? () => setState(() => _quantity--)
                                        : null,
                                  ),
                                  SizedBox(
                                    width: 26,
                                    child: Text(
                                      '$_quantity',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: colors.onSurface,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 16),
                                    splashRadius: 18,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 36,
                                    ),
                                    onPressed: () => setState(() => _quantity++),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 12),

                            // ADD TO ORDER BUTTON
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: () {
                                    final posController = Get.isRegistered<PosController>()
                                        ? Get.find<PosController>()
                                        : null;

                                    if (posController != null) {
                                      posController.addCustomizedItemToCart(
                                        product: widget.product,
                                        size: _selectedSize,
                                        extras: _selectedExtras.toList(),
                                        quantity: _quantity,
                                      );
                                    }
                                    Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    'Add to Order · Rs ${_calculatedTotalPrice.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
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
          ],
        ),
      ),
    );
  }
}
