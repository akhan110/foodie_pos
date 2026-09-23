enum ProductCategory { burgers, chicken, pizza, sides, drinks, desserts, deals }

class ProductCategoryModel {
  final String id;
  final String name;
  final String slug;
  final String? icon;
  final int productCount;

  ProductCategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.productCount = 0,
  });

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) {
    return ProductCategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      icon: json['icon']?.toString(),
      productCount: (json['product_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'icon': icon,
      'product_count': productCount,
    };
  }

  ProductCategoryModel copyWith({
    String? id,
    String? name,
    String? slug,
    String? icon,
    int? productCount,
  }) {
    return ProductCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      icon: icon ?? this.icon,
      productCount: productCount ?? this.productCount,
    );
  }
}
