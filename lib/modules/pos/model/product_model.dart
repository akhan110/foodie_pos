import 'product_category.dart';

class ProductModel {
  const ProductModel({
    required this.id,
    this.sku,
    required this.name,
    required this.category,
    this.categoryId,
    this.categoryName,
    required this.price,
    required this.image,
    this.description,
    this.isPopular = false,
    this.isCombo = false,
    this.isKitchen = true,
    this.isActive = true,
  });

  final String id;
  final String? sku;
  final String name;
  final ProductCategory category;
  final String? categoryId;
  final String? categoryName;
  final double price;
  final String image;
  final String? description;
  final bool isPopular;
  final bool isCombo;
  final bool isKitchen;
  final bool isActive;

  String get effectiveSku => sku ?? '${category.name.substring(0, category.name.length >= 3 ? 3 : category.name.length).toUpperCase()}-${id.length >= 3 ? id.substring(id.length - 3).toUpperCase() : "001"}';

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    ProductCategory parseCategory(String? cat) {
      if (cat == null) return ProductCategory.burgers;
      return ProductCategory.values.firstWhere(
        (e) => e.name.toLowerCase() == cat.toLowerCase(),
        orElse: () => ProductCategory.burgers,
      );
    }

    final rawCatId = json['category_id']?.toString() ?? json['categoryId']?.toString();
    final rawCatName = json['category_name']?.toString() ?? json['category']?.toString();
    final catEnum = parseCategory(rawCatName ?? rawCatId);
    final rawId = json['id']?.toString() ?? '';

    return ProductModel(
      id: rawId,
      sku: json['sku']?.toString() ?? '${catEnum.name.substring(0, catEnum.name.length >= 3 ? 3 : catEnum.name.length).toUpperCase()}-${rawId.length >= 3 ? rawId.substring(rawId.length - 3).toUpperCase() : "001"}',
      name: json['name']?.toString() ?? '',
      category: catEnum,
      categoryId: rawCatId ?? catEnum.name,
      categoryName: rawCatName ?? catEnum.name,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description']?.toString(),
      image: json['image']?.toString() ?? 'assets/svg/products/burger.svg',
      isPopular: json['is_popular'] as bool? ?? json['isPopular'] as bool? ?? false,
      isCombo: json['is_combo'] as bool? ?? json['isCombo'] as bool? ?? false,
      isKitchen: json['is_kitchen'] as bool? ?? json['isKitchen'] as bool? ?? true,
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku ?? effectiveSku,
      'name': name,
      'category_id': categoryId ?? category.name,
      'category': categoryName ?? category.name,
      'price': price,
      'description': description,
      'image': image,
      'is_popular': isPopular,
      'is_combo': isCombo,
      'is_kitchen': isKitchen,
      'is_active': isActive,
    };
  }

  ProductModel copyWith({
    String? id,
    String? sku,
    String? name,
    ProductCategory? category,
    String? categoryId,
    String? categoryName,
    double? price,
    String? image,
    String? description,
    bool? isPopular,
    bool? isCombo,
    bool? isKitchen,
    bool? isActive,
  }) {
    return ProductModel(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      price: price ?? this.price,
      image: image ?? this.image,
      description: description ?? this.description,
      isPopular: isPopular ?? this.isPopular,
      isCombo: isCombo ?? this.isCombo,
      isKitchen: isKitchen ?? this.isKitchen,
      isActive: isActive ?? this.isActive,
    );
  }
}
