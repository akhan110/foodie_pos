import 'package:flutter/material.dart';
import 'package:foodiepos/app/widgets/custom_text_widget.dart';
import 'package:foodiepos/modules/pos/widgets/new_order/right_view_cart/cart_item_list.dart';
import 'package:foodiepos/modules/pos/widgets/new_order/right_view_cart/order_type_tabs.dart';

class CartSection extends StatelessWidget {
  const CartSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: CustomTextWidget(
                    'Current Order',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () {},
                  child: CustomTextWidget(
                    'Clear all',
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: OrderTypeTabs(),
            ),
            const SizedBox(height: 12),
            const Expanded(child: CartItemList()),
          ],
        ),
      ),
    );
  }
}
