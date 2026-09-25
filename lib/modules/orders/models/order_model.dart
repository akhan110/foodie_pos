import 'package:flutter/material.dart';

String _formatCurrency(double amount) {
  final whole = amount.round().toString();
  final buffer = StringBuffer();
  final len = whole.length;
  for (int i = 0; i < len; i++) {
    if (i > 0 && (len - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(whole[i]);
  }
  return buffer.toString();
}

String _formatTime(DateTime dt) {
  final hour = dt.hour;
  final minute = dt.minute.toString().padLeft(2, '0');
  final period = hour >= 12 ? 'PM' : 'AM';
  final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
  return '$displayHour:$minute $period';
}

const _monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

String _formatDate(DateTime dt) {
  final month = _monthNames[dt.month - 1];
  return '$month ${dt.day}, ${dt.year}';
}

class OrderItemModel {
  final String id;
  final String orderId;
  final String? productId;
  final String productName;
  final String productImage;
  final String size;
  final String? addons;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final int prepTimeMinutes;

  const OrderItemModel({
    required this.id,
    required this.orderId,
    this.productId,
    required this.productName,
    this.productImage = 'assets/svg/products/burger.svg',
    this.size = 'Regular',
    this.addons,
    this.quantity = 1,
    required this.unitPrice,
    required this.totalPrice,
    this.prepTimeMinutes = 3,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      productId: json['product_id']?.toString(),
      productName: json['product_name']?.toString() ?? 'Item',
      productImage: json['product_image']?.toString() ?? 'assets/svg/products/burger.svg',
      size: json['size']?.toString() ?? 'Regular',
      addons: json['addons']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      prepTimeMinutes: (json['prep_time_minutes'] as num?)?.toInt() ?? (json['prepTimeMinutes'] as num?)?.toInt() ?? 3,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'size': size,
      'addons': addons,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'prep_time_minutes': prepTimeMinutes,
    };
  }

  String get formattedTotalPrice => 'Rs ${_formatCurrency(totalPrice)}';
  String get formattedUnitPrice => 'Rs ${_formatCurrency(unitPrice)}';
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String orderType;
  final String status;
  final String? tableNumber;
  final String cashierName;
  final String paymentMethod;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final double amountReceived;
  final double changeAmount;
  final DateTime createdAt;
  final int itemsCount;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.orderType,
    required this.status,
    this.tableNumber,
    this.cashierName = 'Akhan',
    this.paymentMethod = 'Cash',
    required this.subtotal,
    this.tax = 0.0,
    this.discount = 0.0,
    required this.total,
    required this.amountReceived,
    this.changeAmount = 0.0,
    required this.createdAt,
    this.itemsCount = 0,
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    if (json['created_at'] != null) {
      parsedDate = DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    final rawItems = json['items'] as List<dynamic>? ?? [];
    final parsedItems = rawItems
        .map((e) => OrderItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    final calculatedCount = parsedItems.isNotEmpty
        ? parsedItems.fold<int>(0, (sum, it) => sum + it.quantity)
        : (json['items_count'] as num?)?.toInt() ?? 0;

    return OrderModel(
      id: json['id']?.toString() ?? '',
      orderNumber: json['order_number']?.toString() ?? '#0000',
      orderType: json['order_type']?.toString() ?? 'Dine in',
      status: json['status']?.toString() ?? 'Completed',
      tableNumber: json['table_number']?.toString() ?? 'Table 1',
      cashierName: json['cashier_name']?.toString() ?? 'Akhan',
      paymentMethod: json['payment_method']?.toString() ?? 'Cash',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      amountReceived: (json['amount_received'] as num?)?.toDouble() ?? 0.0,
      changeAmount: (json['change_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: parsedDate,
      itemsCount: calculatedCount,
      items: parsedItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'order_type': orderType,
      'status': status,
      'table_number': tableNumber,
      'cashier_name': cashierName,
      'payment_method': paymentMethod,
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total': total,
      'amount_received': amountReceived,
      'change_amount': changeAmount,
      'created_at': createdAt.toIso8601String(),
      'items_count': itemsCount,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? orderType,
    String? status,
    String? tableNumber,
    String? cashierName,
    String? paymentMethod,
    double? subtotal,
    double? tax,
    double? discount,
    double? total,
    double? amountReceived,
    double? changeAmount,
    DateTime? createdAt,
    int? itemsCount,
    List<OrderItemModel>? items,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      orderType: orderType ?? this.orderType,
      status: status ?? this.status,
      tableNumber: tableNumber ?? this.tableNumber,
      cashierName: cashierName ?? this.cashierName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      amountReceived: amountReceived ?? this.amountReceived,
      changeAmount: changeAmount ?? this.changeAmount,
      createdAt: createdAt ?? this.createdAt,
      itemsCount: itemsCount ?? this.itemsCount,
      items: items ?? this.items,
    );
  }

  String get formattedTime => _formatTime(createdAt.toLocal());
  String get formattedDate => _formatDate(createdAt.toLocal());

  int get targetPrepMinutes {
    if (items.isEmpty) return 3;
    int maxMins = 3;
    for (final it in items) {
      if (it.prepTimeMinutes > maxMins) {
        maxMins = it.prepTimeMinutes;
      }
    }
    return maxMins;
  }

  int get targetPrepSeconds => targetPrepMinutes * 60;

  String get formattedCompletedSubtitle {
    final now = DateTime.now();
    final localCreated = createdAt.toLocal();
    final isToday = now.year == localCreated.year &&
        now.month == localCreated.month &&
        now.day == localCreated.day;

    final timeStr = _formatTime(localCreated);
    if (isToday) {
      return '$status today at $timeStr';
    }
    final month = _monthNames[localCreated.month - 1];
    return '$status on $month ${localCreated.day} at $timeStr';
  }

  String get formattedTotal => 'Rs ${_formatCurrency(total)}';
  String get formattedSubtotal => 'Rs ${_formatCurrency(subtotal)}';
  String get formattedTax => 'Rs ${_formatCurrency(tax)}';
  String get formattedDiscount => 'Rs ${_formatCurrency(discount)}';
  String get formattedReceived => 'Rs ${_formatCurrency(amountReceived)}';
  String get formattedChange => 'Rs ${_formatCurrency(changeAmount)}';

  Color get statusBadgeBgColor {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFFE6F9F0);
      case 'preparing':
      case 'pending':
        return const Color(0xFFE8F2FF);
      case 'voided':
      case 'cancelled':
        return const Color(0xFFFFECEC);
      default:
        return const Color(0xFFF1F3F7);
    }
  }

  Color get statusBadgeTextColor {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF10B981);
      case 'preparing':
      case 'pending':
        return const Color(0xFF3B82F6);
      case 'voided':
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
