import 'package:flutter/material.dart';
import 'package:foodiepos/modules/pos/widgets/new_order/left_view_products/new_order_header.dart';
import 'package:foodiepos/modules/pos/widgets/new_order/left_view_products/product_grid.dart';


class ProductSection extends StatelessWidget {
  const ProductSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NewOrderHeader(),
            const SizedBox(height: 16),
            Expanded(child: ProductGrid()),
          ],
        ),
      ),
    );
  }
}
