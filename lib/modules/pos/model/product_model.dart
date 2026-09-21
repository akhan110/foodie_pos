import 'product_category.dart';

class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.image,
    this.isPopular = false,
    this.isCombo = false,
  });

  final String id;
  final String name;
  final ProductCategory category;
  final double price;
  final String image;
  final bool isPopular;
  final bool isCombo;
}
