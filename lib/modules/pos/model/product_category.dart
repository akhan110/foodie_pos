enum ProductCategory { burgers, chicken, pizza, sides, drinks, desserts, deals }

class ProductCategoryModel {
  final String id;
  final String name;
  final String slug;
  final String? icon;

  ProductCategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
  });

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) {
    return ProductCategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      icon: json['icon']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'icon': icon,
    };
  }
}
