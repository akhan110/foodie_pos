import 'package:flutter/material.dart';
import 'package:foodiepos/app/constants/assets_svg.dart';

import 'cart_item_tile.dart';

class CartItemList extends StatelessWidget {
  const CartItemList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        CartItemTile(
          name: 'Classic Smash Burger',
          subtitle: 'Regular',
          price: 1240,
          quantity: 2,
          image: AssetsSvg.burger,
          onRemove: () {},
        ),

        SizedBox(height: 8),

        CartItemTile(
          name: 'Sea Salt Fries',
          subtitle: 'Regular',
          price: 260,
          quantity: 1,
          image: AssetsSvg.fries,
          onRemove: () {},
        ),

        SizedBox(height: 8),

        CartItemTile(
          name: 'Cola',
          subtitle: 'Regular',
          price: 360,
          quantity: 2,
          image: AssetsSvg.drink,
          onRemove: () {},
        ),
      ],
    );
  }
}
