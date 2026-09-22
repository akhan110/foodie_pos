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

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    ProductCategory parseCategory(String? cat) {
      if (cat == null) return ProductCategory.burgers;
      return ProductCategory.values.firstWhere(
        (e) => e.name.toLowerCase() == cat.toLowerCase(),
        orElse: () => ProductCategory.burgers,
      );
    }

    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: parseCategory(json['category']?.toString() ?? json['category_name']?.toString()),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      image: json['image']?.toString() ?? 'assets/svg/products/burger.svg',
      isPopular: json['is_popular'] as bool? ?? json['isPopular'] as bool? ?? false,
      isCombo: json['is_combo'] as bool? ?? json['isCombo'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'price': price,
      'image': image,
      'is_popular': isPopular,
      'is_combo': isCombo,
    };
  }
}
