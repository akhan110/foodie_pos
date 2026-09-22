class TopSellingItemModel {
  final String name;
  final int quantity;
  final double price;
  final String image;

  TopSellingItemModel({
    required this.name,
    required this.quantity,
    required this.price,
    required this.image,
  });

  factory TopSellingItemModel.fromJson(Map<String, dynamic> json) {
    return TopSellingItemModel(
      name: json['name']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? (json['total'] as num?)?.toDouble() ?? 0.0,
      image: json['image']?.toString() ?? 'assets/svg/products/burger.svg',
    );
  }
}

class RecentOrderRowModel {
  final String orderNumber;
  final String time;
  final String orderType;
  final int itemsCount;
  final double total;
  final String status;

  RecentOrderRowModel({
    required this.orderNumber,
    required this.time,
    required this.orderType,
    required this.itemsCount,
    required this.total,
    required this.status,
  });

  factory RecentOrderRowModel.fromJson(Map<String, dynamic> json) {
    return RecentOrderRowModel(
      orderNumber: json['order_number']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      orderType: json['order_type']?.toString() ?? 'Dine In',
      itemsCount: (json['items_count'] as num?)?.toInt() ?? 1,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'Completed',
    );
  }
}

class OrderTypeStatModel {
  final String type;
  final int percentage;
  final int count;

  OrderTypeStatModel({
    required this.type,
    required this.percentage,
    required this.count,
  });

  factory OrderTypeStatModel.fromJson(Map<String, dynamic> json) {
    return OrderTypeStatModel(
      type: json['type']?.toString() ?? '',
      percentage: (json['percentage'] as num?)?.toInt() ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

class HourlyDataPoint {
  final String label;
  final double revenue;
  final int orders;

  HourlyDataPoint({
    required this.label,
    required this.revenue,
    required this.orders,
  });

  factory HourlyDataPoint.fromJson(Map<String, dynamic> json) {
    return HourlyDataPoint(
      label: json['label']?.toString() ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      orders: (json['orders'] as num?)?.toInt() ?? 0,
    );
  }
}

class DashboardModel {
  final double totalRevenue;
  final String revenueChange;
  final int completedOrders;
  final String ordersChange;
  final double avgOrderValue;
  final String aovChange;
  final double taxesAndDiscounts;
  final String taxChange;
  final String comparisonLabel;
  final List<HourlyDataPoint> hourlyData;
  final List<OrderTypeStatModel> orderTypes;
  final List<TopSellingItemModel> topSellingItems;
  final List<RecentOrderRowModel> recentOrders;
  final Map<String, Map<String, dynamic>> paymentMethods;

  DashboardModel({
    required this.totalRevenue,
    required this.revenueChange,
    required this.completedOrders,
    required this.ordersChange,
    required this.avgOrderValue,
    required this.aovChange,
    required this.taxesAndDiscounts,
    required this.taxChange,
    this.comparisonLabel = 'vs. yesterday',
    required this.hourlyData,
    required this.orderTypes,
    required this.topSellingItems,
    required this.recentOrders,
    required this.paymentMethods,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final hourlyRaw = (json['hourly_data'] as List<dynamic>?) ?? [];
    final hourlyList = hourlyRaw
        .map((e) => HourlyDataPoint.fromJson(e as Map<String, dynamic>))
        .toList();

    final typesRaw = (json['order_types'] as List<dynamic>?) ?? [];
    final typesList = typesRaw
        .map((e) => OrderTypeStatModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final topRaw = (json['top_selling_items'] as List<dynamic>?) ?? [];
    final topList = topRaw
        .map((e) => TopSellingItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final recentRaw = (json['recent_orders'] as List<dynamic>?) ?? [];
    final recentList = recentRaw
        .map((e) => RecentOrderRowModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final pmMap = <String, Map<String, dynamic>>{};
    if (json['payment_methods'] is Map<String, dynamic>) {
      (json['payment_methods'] as Map<String, dynamic>).forEach((k, v) {
        if (v is Map<String, dynamic>) {
          pmMap[k] = v;
        }
      });
    }

    return DashboardModel(
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      revenueChange: json['revenue_change']?.toString() ?? '+0.0%',
      completedOrders: (json['completed_orders'] as num?)?.toInt() ?? 0,
      ordersChange: json['orders_change']?.toString() ?? '+0.0%',
      avgOrderValue: (json['avg_order_value'] as num?)?.toDouble() ?? 0.0,
      aovChange: json['aov_change']?.toString() ?? '+0.0%',
      taxesAndDiscounts: (json['taxes_and_discounts'] as num?)?.toDouble() ?? 0.0,
      taxChange: json['tax_change']?.toString() ?? '+0.0%',
      comparisonLabel: json['comparison_label']?.toString() ?? 'vs. yesterday',
      hourlyData: hourlyList,
      orderTypes: typesList,
      topSellingItems: topList,
      recentOrders: recentList,
      paymentMethods: pmMap,
    );
  }
}
