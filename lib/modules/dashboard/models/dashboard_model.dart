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
    required this.hourlyData,
    required this.orderTypes,
    required this.topSellingItems,
    required this.recentOrders,
    required this.paymentMethods,
  });
}
