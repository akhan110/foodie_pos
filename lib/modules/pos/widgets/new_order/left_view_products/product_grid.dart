import 'package:flutter/material.dart';
import 'package:foodiepos/data/data/dummy/dummy_model_data.dart';
import 'package:foodiepos/modules/pos/widgets/new_order/left_view_products/product_card.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final products = ProductDummyData.products;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        int crossAxisCount;

        if (width >= 1100) {
          crossAxisCount = 5;
        } else if (width >= 850) {
          crossAxisCount = 4;
        } else if (width >= 620) {
          crossAxisCount = 3;
        } else {
          crossAxisCount = 2;
        }

        return GridView.builder(
          padding: EdgeInsets.zero,
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,

            // Better than childAspectRatio for your card
            mainAxisExtent: 220,
          ),
          itemBuilder: (context, index) {
            return ProductCard(product: products[index]);
          },
        );
      },
    );
  }
}
