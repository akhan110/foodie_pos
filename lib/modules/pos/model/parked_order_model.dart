import 'package:foodiepos/modules/pos/model/cart_model.dart';

class ParkedOrderModel {
  final String id;
  final String label;
  final List<CartItemModel> items;
  final String orderType;
  final DateTime parkedAt;

  ParkedOrderModel({
    required this.id,
    required this.label,
    required this.items,
    required this.orderType,
    required this.parkedAt,
  });

  double get total => items.fold(0.0, (sum, item) => sum + item.subtotal);
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'orderType': orderType,
        'parkedAt': parkedAt.toIso8601String(),
        'items': items
            .map((item) => {
                  'productId': item.product.id,
                  'name': item.product.name,
                  'price': item.product.price,
                  'image': item.product.image,
                  'quantity': item.quantity,
                  'size': item.size.name,
                  'sizeExtraPrice': item.size.extraPrice,
                  'extras': item.extras.map((e) => e.name).toList(),
                  'notes': item.notes,
                })
            .toList(),
      };
}
