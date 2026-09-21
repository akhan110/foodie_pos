import 'package:flutter/material.dart';
import 'package:foodiepos/modules/pos/widgets/new_order/left_view_products/product_section.dart';
import 'package:foodiepos/modules/pos/widgets/new_order/right_view_cart/cart_section.dart';

class NewOrderView extends StatelessWidget {
  const NewOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        const Expanded(child: ProductSection()),
        VerticalDivider(width: 1, thickness: 1, color: theme.dividerColor),
        const SizedBox(
          width: 360,
          child: CartSection(),
        ),
      ],
    );
  }
}

