class TopSellingItemModel {
  final String name;
  final int quantity;
  final double total;
  final String image;

  TopSellingItemModel({
    required this.name,
    required this.quantity,
    required this.total,
    required this.image,
  });

  factory TopSellingItemModel.fromJson(Map<String, dynamic> json) {
    return TopSellingItemModel(
      name: json['name']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      image: json['image']?.toString() ?? 'assets/svg/products/burger.svg',
    );
  }
}

class DashboardModel {
  final double totalRevenue;
  final int totalOrders;
  final double avgOrderValue;
  final double totalDiscount;
  final double totalTax;
  final Map<String, double> paymentBreakdown;
  final List<TopSellingItemModel> topSellingItems;
  final List<double> hourlySales;

  DashboardModel({
    required this.totalRevenue,
    required this.totalOrders,
    required this.avgOrderValue,
    required this.totalDiscount,
    required this.totalTax,
    required this.paymentBreakdown,
    required this.topSellingItems,
    required this.hourlySales,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final payments = <String, double>{};
    if (json['payment_breakdown'] is Map) {
      (json['payment_breakdown'] as Map).forEach((k, v) {
        payments[k.toString()] = (v as num?)?.toDouble() ?? 0.0;
      });
    }

    final topList = <TopSellingItemModel>[];
    if (json['top_selling_items'] is List) {
      for (final item in json['top_selling_items']) {
        if (item is Map<String, dynamic>) {
          topList.add(TopSellingItemModel.fromJson(item));
        }
      }
    }

    final hours = <double>[];
    if (json['hourly_sales'] is List) {
      for (final h in json['hourly_sales']) {
        hours.add((h as num?)?.toDouble() ?? 0.0);
      }
    }

    return DashboardModel(
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      totalOrders: (json['total_orders'] as num?)?.toInt() ?? 0,
      avgOrderValue: (json['avg_order_value'] as num?)?.toDouble() ?? 0.0,
      totalDiscount: (json['total_discount'] as num?)?.toDouble() ?? 0.0,
      totalTax: (json['total_tax'] as num?)?.toDouble() ?? 0.0,
      paymentBreakdown: payments,
      topSellingItems: topList,
      hourlySales: hours.isNotEmpty ? hours : List.filled(24, 0.0),
    );
  }
}
