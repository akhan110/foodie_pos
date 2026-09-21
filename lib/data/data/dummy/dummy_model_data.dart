import 'package:foodiepos/app/constants/assets_svg.dart';
import 'package:foodiepos/modules/pos/model/product_category.dart';
import 'package:foodiepos/modules/pos/model/product_model.dart';

class ProductDummyData {
  ProductDummyData._();

  static const List<ProductModel> products = [
    ProductModel(
      id: '1',
      name: 'Classic Smash Burger',
      category: ProductCategory.burgers,
      price: 620,
      image: AssetsSvg.burger,
      isPopular: true,
    ),

    ProductModel(
      id: '2',
      name: 'Crispy Chicken Burger',
      category: ProductCategory.burgers,
      price: 560,
      image: AssetsSvg.burger,
      isPopular: true,
    ),

    ProductModel(
      id: '3',
      name: 'Pepperoni Pizza',
      category: ProductCategory.pizza,
      price: 890,
      image: AssetsSvg.pizza,
      isPopular: true,
    ),

    ProductModel(
      id: '4',
      name: 'Crunch Chicken',
      category: ProductCategory.chicken,
      price: 740,
      image: AssetsSvg.chicken,
    ),

    ProductModel(
      id: '5',
      name: 'Sea Salt Fries',
      category: ProductCategory.sides,
      price: 260,
      image: AssetsSvg.fries,
    ),

    ProductModel(
      id: '6',
      name: 'BBQ Chicken Pizza',
      category: ProductCategory.pizza,
      price: 920,
      image: AssetsSvg.pizza,
    ),

    ProductModel(
      id: '7',
      name: 'Cola',
      category: ProductCategory.drinks,
      price: 180,
      image: AssetsSvg.drink,
      isPopular: true,
    ),

    ProductModel(
      id: '8',
      name: 'Chocolate Sundae',
      category: ProductCategory.desserts,
      price: 320,
      image: AssetsSvg.dessert,
    ),

    // COMBO EXAMPLES
    ProductModel(
      id: '9',
      name: 'Smash Burger Combo',
      category: ProductCategory.burgers,
      price: 950,
      image: AssetsSvg.burger,
      isPopular: true,
      isCombo: true,
    ),

    ProductModel(
      id: '10',
      name: 'Chicken Combo',
      category: ProductCategory.chicken,
      price: 890,
      image: AssetsSvg.chicken,
      isCombo: true,
    ),
  ];
}
