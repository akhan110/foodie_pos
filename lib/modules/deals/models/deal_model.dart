class DealItemModel {
  final String id;
  final String? dealId;
  final String? productId;
  final String productName;
  final String productImage;
  int quantity;
  double unitPrice;
  double totalPrice;

  DealItemModel({
    required this.id,
    this.dealId,
    this.productId,
    required this.productName,
    this.productImage = 'assets/svg/products/burger.svg',
    this.quantity = 1,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory DealItemModel.fromJson(Map<String, dynamic> json) {
    final qty = (json['quantity'] as num?)?.toInt() ?? 1;
    final uPrice = (json['unit_price'] as num?)?.toDouble() ?? 0.0;
    final tPrice = (json['total_price'] as num?)?.toDouble() ?? (uPrice * qty);

    return DealItemModel(
      id: json['id']?.toString() ?? '',
      dealId: json['deal_id']?.toString(),
      productId: json['product_id']?.toString(),
      productName: json['product_name']?.toString() ?? '',
      productImage: json['product_image']?.toString() ?? 'assets/svg/products/burger.svg',
      quantity: qty,
      unitPrice: uPrice,
      totalPrice: tPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (dealId != null) 'deal_id': dealId,
      if (productId != null) 'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }

  DealItemModel copyWith({
    String? id,
    String? dealId,
    String? productId,
    String? productName,
    String? productImage,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
  }) {
    return DealItemModel(
      id: id ?? this.id,
      dealId: dealId ?? this.dealId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}

class DealModel {
  final String id;
  String name;
  String? description;
  String category;
  double price;
  double originalPrice;
  double discountAmount;
  String image;
  bool isActive;
  final dynamic createdAt;
  List<DealItemModel> items;

  DealModel({
    required this.id,
    required this.name,
    this.description,
    this.category = 'Meal Combos',
    required this.price,
    this.originalPrice = 0.0,
    this.discountAmount = 0.0,
    this.image = 'assets/svg/products/burger.svg',
    this.isActive = true,
    this.createdAt,
    this.items = const [],
  });

  factory DealModel.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>?) ?? [];
    final itemsList = rawItems
        .map((e) => DealItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return DealModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      category: json['category']?.toString() ?? 'Meal Combos',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['original_price'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      image: json['image']?.toString() ?? 'assets/svg/products/burger.svg',
      isActive: json['is_active'] == true || json['is_active'] == 1,
      createdAt: json['created_at'],
      items: itemsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'original_price': originalPrice,
      'discount_amount': discountAmount,
      'image': image,
      'is_active': isActive,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  DealModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? price,
    double? originalPrice,
    double? discountAmount,
    String? image,
    bool? isActive,
    dynamic createdAt,
    List<DealItemModel>? items,
  }) {
    return DealModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      discountAmount: discountAmount ?? this.discountAmount,
      image: image ?? this.image,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }
}
