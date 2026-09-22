import 'package:flutter/material.dart';
import 'package:foodiepos/modules/dashboard/models/dashboard_model.dart';
import 'package:foodiepos/services/network/api_request_type.dart';
import 'package:foodiepos/services/network/network.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final Network _network = Network.instance;

  final Rx<DashboardModel?> data = Rx<DashboardModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString selectedTimeRange = 'Today'.obs; // 'Today', 'This Week', 'This Month'

  @override
  void onInit() {
    super.onInit();
    fetchAnalytics();
  }

  Future<void> fetchAnalytics({bool showSpinner = true}) async {
    try {
      if (showSpinner) isLoading.value = true;

      final response = await _network.apiRequest<DashboardModel>(
        requestType: ApiRequestType.get,
        endPoint: '/api/v1/analytics/overview',
        isBearerRequired: false,
        parser: (json) => DashboardModel.fromJson(json as Map<String, dynamic>),
      );

      if (response.success && response.data != null) {
        data.value = response.data;
      } else {
        _setFallbackData();
      }
    } catch (e) {
      debugPrint('Error loading analytics: $e');
      _setFallbackData();
    } finally {
      isLoading.value = false;
    }
  }

  void setTimeRange(String range) {
    selectedTimeRange.value = range;
    fetchAnalytics(showSpinner: false);
  }

  void _setFallbackData() {
    data.value = DashboardModel(
      totalRevenue: 28450.0,
      totalOrders: 32,
      avgOrderValue: 889.0,
      totalDiscount: 1450.0,
      totalTax: 3920.0,
      paymentBreakdown: {
        'Cash': 18200.0,
        'Card': 7850.0,
        'QR Pay': 2400.0,
      },
      topSellingItems: [
        TopSellingItemModel(name: 'Classic Smash Burger', quantity: 24, total: 14880.0, image: 'assets/svg/products/burger.svg'),
        TopSellingItemModel(name: 'BBQ Chicken Pizza', quantity: 12, total: 11040.0, image: 'assets/svg/products/pizza.svg'),
        TopSellingItemModel(name: 'Crunch Chicken', quantity: 18, total: 13320.0, image: 'assets/svg/products/chicken.svg'),
        TopSellingItemModel(name: 'Sea Salt Fries', quantity: 30, total: 7800.0, image: 'assets/svg/products/fries.svg'),
        TopSellingItemModel(name: 'Cola', quantity: 45, total: 8100.0, image: 'assets/svg/products/drink.svg'),
      ],
      hourlySales: [
        0, 0, 0, 0, 0, 0, 0, 0, 0, // 0-8 AM
        850, 2400, 4200, 6800, 3900, 2100, 1800, 3200, 5400, 7200, 4800, 2100, 600, 0, 0
      ],
    );
  }
}
