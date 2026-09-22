import 'package:flutter/material.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/app/widgets/app_image_widget.dart';
import 'package:foodiepos/app/widgets/custom_text_widget.dart';
import 'package:foodiepos/modules/pos/controllers/pos_controller.dart';
import 'package:foodiepos/modules/pos/model/product_model.dart';
import 'package:foodiepos/modules/pos/widgets/new_order/dialogs/product_customization_dialog.dart';
import 'package:get/get.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final posController = Get.isRegistered<PosController>()
        ? Get.find<PosController>()
        : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => ProductCustomizationDialog.show(context, product),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE THUMBNAIL
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AppImageWidget(
                    imagePath: product.image,
                    fit: BoxFit.contain,
                    borderRadius: BorderRadius.circular(10),
                    fallbackIconSize: 40,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // PRODUCT NAME
              CustomTextWidget(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 6),

              // PRICE & DIRECT ADD/STEPPER CONTROLS
              Row(
                children: [
                  Expanded(
                    child: CustomTextWidget(
                      'Rs ${product.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  if (posController != null)
                    Obx(() {
                      final inCartCount =
                          posController.getProductCartQuantity(product.id);

                      if (inCartCount > 0) {
                        return Container(
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () =>
                                    posController.quickDecrementProduct(product),
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(8),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  child: Icon(
                                    Icons.remove,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Text(
                                '$inCartCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              InkWell(
                                onTap: () =>
                                    posController.quickIncrementProduct(product),
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(8),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () =>
                              posController.quickIncrementProduct(product),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const CustomTextWidget(
                            '+ Add',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    })
                  else
                    SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () =>
                            ProductCustomizationDialog.show(context, product),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const CustomTextWidget(
                          '+ Add',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
