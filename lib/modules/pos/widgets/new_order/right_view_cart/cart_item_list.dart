import 'package:flutter/material.dart';
import 'package:foodiepos/app/widgets/custom_text_widget.dart';
import 'package:foodiepos/modules/pos/controllers/pos_controller.dart';
import 'package:get/get.dart';

import 'cart_item_tile.dart';

class CartItemList extends GetView<PosController> {
  const CartItemList({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Obx(() {
      final items = controller.cartItems;

      if (items.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 48,
                color: colors.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 10),
              CustomTextWidget(
                'Cart is empty',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              CustomTextWidget(
                'Tap items from the menu to add',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final cartItem = items[index];
          return CartItemTile(
            name: cartItem.product.name,
            subtitle: cartItem.product.category.name.capitalizeFirst ?? 'Regular',
            price: cartItem.subtotal,
            quantity: cartItem.quantity,
            image: cartItem.product.image,
            onRemove: () => controller.removeFromCart(cartItem.product.id),
            onIncrease: () => controller.incrementQuantity(cartItem.product.id),
            onDecrease: () => controller.decrementQuantity(cartItem.product.id),
          );
        },
      );
    });
  }
}
