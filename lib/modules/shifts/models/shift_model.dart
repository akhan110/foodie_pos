class ShiftModel {
  final String id;
  final String? cashierId;
  final String cashierName;
  final double openingFloat;
  final double? closingCash;
  final double expectedCash;
  final double? cashDifference;
  final double totalSales;
  final double cashSales;
  final double cardSales;
  final int totalOrders;
  final String status;
  final String? notes;
  final DateTime? openedAt;
  final DateTime? closedAt;

  ShiftModel({
    required this.id,
    this.cashierId,
    required this.cashierName,
    required this.openingFloat,
    this.closingCash,
    required this.expectedCash,
    this.cashDifference,
    required this.totalSales,
    required this.cashSales,
    required this.cardSales,
    required this.totalOrders,
    required this.status,
    this.notes,
    this.openedAt,
    this.closedAt,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      id: json['id']?.toString() ?? '',
      cashierId: json['cashier_id']?.toString(),
      cashierName: json['cashier_name']?.toString() ?? 'Alex Khan',
      openingFloat: (json['opening_float'] as num?)?.toDouble() ?? 0.0,
      closingCash: (json['closing_cash'] as num?)?.toDouble(),
      expectedCash: (json['expected_cash'] as num?)?.toDouble() ?? 0.0,
      cashDifference: (json['cash_difference'] as num?)?.toDouble(),
      totalSales: (json['total_sales'] as num?)?.toDouble() ?? 0.0,
      cashSales: (json['cash_sales'] as num?)?.toDouble() ?? 0.0,
      cardSales: (json['card_sales'] as num?)?.toDouble() ?? 0.0,
      totalOrders: (json['total_orders'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'open',
      notes: json['notes']?.toString(),
      openedAt: json['opened_at'] != null ? DateTime.tryParse(json['opened_at'].toString()) : null,
      closedAt: json['closed_at'] != null ? DateTime.tryParse(json['closed_at'].toString()) : null,
    );
  }
}
