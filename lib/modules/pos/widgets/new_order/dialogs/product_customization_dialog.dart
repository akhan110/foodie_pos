import 'package:flutter/material.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/app/widgets/app_image_widget.dart';
import 'package:foodiepos/app/widgets/custom_text_widget.dart';
import 'package:foodiepos/modules/pos/controllers/pos_controller.dart';
import 'package:foodiepos/modules/pos/model/cart_model.dart';
import 'package:foodiepos/modules/pos/model/product_model.dart';
import 'package:foodiepos/modules/pos/repository/pos_repository.dart';
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
  final IPosRepository _repository = PosRepository();

  List<ProductSizeOption> _sizes = [];
  List<ProductExtraItem> _availableExtras = [];

  ProductSizeOption? _selectedSize;
  final Set<ProductExtraItem> _selectedExtras = {};
  int _quantity = 1;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomizationFromApi();
  }

  Future<void> _loadCustomizationFromApi() async {
    final cat = widget.product.category.name.toLowerCase();

    try {
      final results = await Future.wait([
        _repository.getSizeOptions(categoryId: cat),
        _repository.getAddons(categoryId: cat),
      ]);

      final sizeRes = results[0] as dynamic;
      final addonRes = results[1] as dynamic;

      if (mounted) {
        setState(() {
          if (sizeRes.success && sizeRes.data != null && (sizeRes.data as List).isNotEmpty) {
            _sizes = List<ProductSizeOption>.from(sizeRes.data);
          } else {
            _sizes = _fallbackSizes(cat);
          }

          if (addonRes.success && addonRes.data != null && (addonRes.data as List).isNotEmpty) {
            _availableExtras = List<ProductExtraItem>.from(addonRes.data);
          } else {
            _availableExtras = _fallbackExtras(cat);
          }

          _selectedSize = _sizes.isNotEmpty ? _sizes.first : const ProductSizeOption(id: 'regular', name: 'Regular', extraPrice: 0);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _sizes = _fallbackSizes(cat);
          _availableExtras = _fallbackExtras(cat);
          _selectedSize = _sizes.first;
          _isLoading = false;
        });
      }
    }
  }

  List<ProductSizeOption> _fallbackSizes(String cat) {
    if (cat.contains('drink')) {
      return const [
        ProductSizeOption(id: 'dr_reg', name: 'Regular', extraPrice: 0.0),
        ProductSizeOption(id: 'dr_lrg', name: 'Large', extraPrice: 60.0),
        ProductSizeOption(id: 'dr_jumbo', name: 'Jumbo', extraPrice: 110.0),
      ];
    } else if (cat.contains('pizza')) {
      return const [
        ProductSizeOption(id: 'pz_reg', name: 'Regular', extraPrice: 0.0),
        ProductSizeOption(id: 'pz_med', name: 'Medium', extraPrice: 220.0),
        ProductSizeOption(id: 'pz_lrg', name: 'Large', extraPrice: 420.0),
      ];
    }
    return const [
      ProductSizeOption(id: 'regular', name: 'Regular', extraPrice: 0.0),
      ProductSizeOption(id: 'large', name: 'Large', extraPrice: 120.0),
      ProductSizeOption(id: 'xl', name: 'XL', extraPrice: 220.0),
    ];
  }

  List<ProductExtraItem> _fallbackExtras(String cat) {
    if (cat.contains('dessert') || cat.contains('sundae')) {
      return const [
        ProductExtraItem(id: 'd_choc_sauce', name: 'Extra chocolate sauce', price: 60.0),
        ProductExtraItem(id: 'd_whipped_cream', name: 'Whipped cream', price: 50.0),
        ProductExtraItem(id: 'd_sprinkles', name: 'Rainbow sprinkles', price: 30.0),
        ProductExtraItem(id: 'd_icecream_scoop', name: 'Vanilla ice cream scoop', price: 100.0),
        ProductExtraItem(id: 'd_choco_chips', name: 'Choco chips', price: 40.0),
      ];
    } else if (cat.contains('drink')) {
      return const [
        ProductExtraItem(id: 'dr_ice', name: 'Extra ice', price: 0.0),
        ProductExtraItem(id: 'dr_lemon', name: 'Lemon slice', price: 20.0),
        ProductExtraItem(id: 'dr_mint', name: 'Fresh mint leaves', price: 30.0),
        ProductExtraItem(id: 'dr_syrup', name: 'Flavored vanilla syrup', price: 50.0),
      ];
    } else if (cat.contains('pizza')) {
      return const [
        ProductExtraItem(id: 'p_cheese', name: 'Extra cheese', price: 120.0),
        ProductExtraItem(id: 'p_mushrooms', name: 'Fresh mushrooms', price: 80.0),
        ProductExtraItem(id: 'p_olives', name: 'Black olives', price: 60.0),
        ProductExtraItem(id: 'p_crust', name: 'Stuffed crust', price: 180.0),
      ];
    }
    return const [
      ProductExtraItem(id: 'b_cheese', name: 'Extra cheese', price: 90.0),
      ProductExtraItem(id: 'b_jalapenos', name: 'Jalapeños', price: 60.0),
      ProductExtraItem(id: 'b_patty', name: 'Extra patty', price: 220.0),
      ProductExtraItem(id: 'b_sauce', name: 'Special sauce', price: 50.0),
    ];
  }

  double get _calculatedUnitPrice {
    final sizeExtra = _selectedSize?.extraPrice ?? 0.0;
    final extrasTotal = _selectedExtras.fold(0.0, (sum, e) => sum + e.price);
    return widget.product.price + sizeExtra + extrasTotal;
  }

  double get _calculatedTotalPrice => _calculatedUnitPrice * _quantity;

  String get _productDescription {
    final cat = widget.product.category.name.toLowerCase();
    if (cat.contains('burger')) {
      return 'Double-seared beef, cheese, lettuce and BiteFlow sauce.';
    } else if (cat.contains('pizza')) {
      return 'Crispy hand-stretched crust topped with rich mozzarella & herbs.';
    } else if (cat.contains('dessert') || cat.contains('sundae')) {
      return 'Rich velvety dessert loaded with premium toppings.';
    } else if (cat.contains('drink')) {
      return 'Chilled refreshing beverage served over ice.';
    } else if (cat.contains('side') || cat.contains('fries')) {
      return 'Freshly fried crispy golden side with custom seasoning.';
    }
    return 'Delicious fresh menu item prepared with quality ingredients.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final dialogBg = isDark ? const Color(0xFF151B26) : Colors.white;
    final graphicBg = isDark ? const Color(0xFF1F2736) : const Color(0xFFFAF5EE);
    final cardBg = isDark ? const Color(0xFF1A2230) : const Color(0xFFF8FAFC);
    final cardBorder = isDark ? const Color(0xFF2B3547) : theme.dividerColor.withValues(alpha: 0.6);
    final pillUnselectedBg = isDark ? const Color(0xFF222B3B) : const Color(0xFFF1F3F5);

    return Dialog(
      backgroundColor: dialogBg,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: cardBorder, width: isDark ? 1.0 : 0.5),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 680,
          maxHeight: 530,
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

            // MAIN CONTENT
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            else
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
                                color: graphicBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: cardBorder),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: AppImageWidget(
                                imagePath: widget.product.image,
                                fit: BoxFit.contain,
                                borderRadius: BorderRadius.circular(12),
                                fallbackIconSize: 56,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // INFO CARD
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: cardBorder),
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
                    // RIGHT COLUMN: Sizes, Addons, Controls
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
                              final isSelected = _selectedSize?.id == sizeOption.id;
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
                                        : pillUnselectedBg,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : cardBorder,
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

                          // EXTRAS CARD (API LOADED)
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: cardBorder),
                              ),
                              child: _availableExtras.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No extras for this item',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      padding: EdgeInsets.zero,
                                      physics: const ClampingScrollPhysics(),
                                      itemCount: _availableExtras.length,
                                      separatorBuilder: (context, index) => Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: cardBorder,
                                      ),
                                      itemBuilder: (context, index) {
                                        final extra = _availableExtras[index];
                                        final isChecked =
                                            _selectedExtras.contains(extra);

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
                                              vertical: 9,
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
                                                    borderRadius:
                                                        BorderRadius.circular(4),
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
                                                    style: theme
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
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
                                                  extra.price == 0
                                                      ? 'Free'
                                                      : '+ Rs ${extra.price.toStringAsFixed(0)}',
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
                                  color: pillUnselectedBg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: cardBorder),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 16),
                                      splashRadius: 18,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
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
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 32,
                                        minHeight: 36,
                                      ),
                                      onPressed: () =>
                                          setState(() => _quantity++),
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
                                      final posController =
                                          Get.isRegistered<PosController>()
                                              ? Get.find<PosController>()
                                              : null;

                                      if (posController != null &&
                                          _selectedSize != null) {
                                        posController.addCustomizedItemToCart(
                                          product: widget.product,
                                          size: _selectedSize!,
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
