import 'package:foodiepos/modules/pos/model/product_model.dart';

class ProductSizeOption {
  final String id;
  final String name;
  final double extraPrice;

  const ProductSizeOption({
    required this.id,
    required this.name,
    this.extraPrice = 0.0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductSizeOption &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ProductExtraItem {
  final String id;
  final String name;
  final double price;

  const ProductExtraItem({
    required this.id,
    required this.name,
    required this.price,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductExtraItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class CartItemModel {
  final String id;
  final ProductModel product;
  int quantity;
  final ProductSizeOption size;
  final List<ProductExtraItem> extras;
  final String? notes;

  CartItemModel({
    String? id,
    required this.product,
    this.quantity = 1,
    this.size = const ProductSizeOption(id: 'regular', name: 'Regular', extraPrice: 0.0),
    this.extras = const [],
    this.notes,
  }) : id = id ?? _generateId(product.id, size, extras);

  static String _generateId(String productId, ProductSizeOption size, List<ProductExtraItem> extras) {
    final extraIds = extras.map((e) => e.id).toList()..sort();
    return '${productId}__${size.id}__${extraIds.join("_")}';
  }

  double get unitPrice =>
      product.price + size.extraPrice + extras.fold(0.0, (sum, item) => sum + item.price);

  double get subtotal => unitPrice * quantity;

  String get subtitle {
    final parts = <String>[size.name];
    if (extras.isNotEmpty) {
      parts.add(extras.map((e) => e.name).join(', '));
    }
    return parts.join(' · ');
  }

  CartItemModel copyWith({
    ProductModel? product,
    int? quantity,
    ProductSizeOption? size,
    List<ProductExtraItem>? extras,
    String? notes,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
      extras: extras ?? this.extras,
      notes: notes ?? this.notes,
    );
  }
}
