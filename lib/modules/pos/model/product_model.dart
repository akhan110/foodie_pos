import 'product_category.dart';

class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.image,
    this.description,
    this.isPopular = false,
    this.isCombo = false,
    this.isActive = true,
  });

  final String id;
  final String name;
  final ProductCategory category;
  final double price;
  final String image;
  final String? description;
  final bool isPopular;
  final bool isCombo;
  final bool isActive;

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
      category: parseCategory(json['category']?.toString() ?? json['category_name']?.toString() ?? json['category_id']?.toString()),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description']?.toString(),
      image: json['image']?.toString() ?? 'assets/svg/products/burger.svg',
      isPopular: json['is_popular'] as bool? ?? json['isPopular'] as bool? ?? false,
      isCombo: json['is_combo'] as bool? ?? json['isCombo'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category_id': category.name,
      'category': category.name,
      'price': price,
      'description': description,
      'image': image,
      'is_popular': isPopular,
      'is_combo': isCombo,
      'is_active': isActive,
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    ProductCategory? category,
    double? price,
    String? image,
    String? description,
    bool? isPopular,
    bool? isCombo,
    bool? isActive,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      image: image ?? this.image,
      description: description ?? this.description,
      isPopular: isPopular ?? this.isPopular,
      isCombo: isCombo ?? this.isCombo,
      isActive: isActive ?? this.isActive,
    );
  }
}
