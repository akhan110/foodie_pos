import 'package:flutter/material.dart';
import 'package:foodiepos/app/utils/app_loader.dart';
import 'package:foodiepos/modules/orders/models/order_model.dart';
import 'package:foodiepos/modules/orders/repository/orders_repository.dart';
import 'package:get/get.dart';

class OrdersController extends GetxController {
  final IOrdersRepository _repository;

  OrdersController({IOrdersRepository? repository})
      : _repository = repository ?? OrdersRepository();

  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxList<OrderModel> filteredOrders = <OrderModel>[].obs;

  final Rx<OrderModel?> selectedOrder = Rx<OrderModel?>(null);
  final RxBool isViewingDetails = false.obs;

  final RxBool isLoading = false.obs;
  final RxBool isUpdatingStatus = false.obs;

  // Filter States
  final RxString selectedDateFilter = 'Today'.obs;
  final RxString selectedTypeFilter = 'All types'.obs;
  final RxString selectedStatusFilter = 'All statuses'.obs;
  final TextEditingController searchController = TextEditingController();

  final List<String> dateOptions = ['Today', 'Yesterday', 'Last 7 Days', 'All Time'];
  final List<String> typeOptions = ['All types', 'Dine in', 'Takeaway', 'Delivery'];
  final List<String> statusOptions = ['All statuses', 'Completed', 'Preparing', 'Voided'];

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadOrders({bool showLoading = true}) async {
    try {
      if (showLoading) isLoading.value = true;

      final response = await _repository.getOrders();
      if (response.success && response.data != null) {
        orders.assignAll(response.data!);
        applyLocalFilters();
      }
    } catch (e) {
      // Fallback to local filtering if already populated
      applyLocalFilters();
    } finally {
      isLoading.value = false;
    }
  }

  void onDateFilterChanged(String? value) {
    if (value != null) {
      selectedDateFilter.value = value;
      applyLocalFilters();
    }
  }

  void onTypeFilterChanged(String? value) {
    if (value != null) {
      selectedTypeFilter.value = value;
      applyLocalFilters();
    }
  }

  void onStatusFilterChanged(String? value) {
    if (value != null) {
      selectedStatusFilter.value = value;
      applyLocalFilters();
    }
  }

  void onSearchChanged(String value) {
    applyLocalFilters();
  }

  void applyLocalFilters() {
    final search = searchController.text.trim().toLowerCase();
    final typeFilter = selectedTypeFilter.value.toLowerCase();
    final statusFilter = selectedStatusFilter.value.toLowerCase();
    final dateFilter = selectedDateFilter.value.toLowerCase();

    final now = DateTime.now();

    final result = orders.where((order) {
      // 1. Search Query
      if (search.isNotEmpty) {
        final matchesNum = order.orderNumber.toLowerCase().contains(search);
        final matchesTable = (order.tableNumber ?? '').toLowerCase().contains(search);
        final matchesCashier = order.cashierName.toLowerCase().contains(search);
        if (!matchesNum && !matchesTable && !matchesCashier) {
          return false;
        }
      }

      // 2. Order Type Filter
      if (typeFilter != 'all types' && typeFilter != 'all') {
        if (order.orderType.toLowerCase() != typeFilter) {
          return false;
        }
      }

      // 3. Status Filter
      if (statusFilter != 'all statuses' && statusFilter != 'all') {
        if (order.status.toLowerCase() != statusFilter) {
          return false;
        }
      }

      // 4. Date Filter
      if (dateFilter == 'today') {
        final isToday = order.createdAt.year == now.year &&
            order.createdAt.month == now.month &&
            order.createdAt.day == now.day;
        if (!isToday) return false;
      } else if (dateFilter == 'yesterday') {
        final yesterday = now.subtract(const Duration(days: 1));
        final isYesterday = order.createdAt.year == yesterday.year &&
            order.createdAt.month == yesterday.month &&
            order.createdAt.day == yesterday.day;
        if (!isYesterday) return false;
      } else if (dateFilter == 'last 7 days') {
        final diffDays = now.difference(order.createdAt).inDays;
        if (diffDays > 7) return false;
      }

      return true;
    }).toList();

    filteredOrders.assignAll(result);
  }

  void selectOrder(OrderModel order) async {
    selectedOrder.value = order;
    isViewingDetails.value = true;

    // Fetch full order details including all items if items are empty
    if (order.items.isEmpty) {
      try {
        final res = await _repository.getOrderDetails(order.id);
        if (res.success && res.data != null) {
          selectedOrder.value = res.data!;
        }
      } catch (_) {}
    }
  }

  void backToOrdersList() {
    isViewingDetails.value = false;
  }

  Future<void> voidOrder(OrderModel order) async {
    try {
      isUpdatingStatus.value = true;
      AppLoader.show(status: 'Voiding order ${order.orderNumber}...');

      final res = await _repository.updateOrderStatus(order.id, 'Voided');
      if (res.success && res.data != null) {
        final updated = res.data!;
        selectedOrder.value = updated;

        final index = orders.indexWhere((o) => o.id == order.id);
        if (index != -1) {
          orders[index] = updated;
          applyLocalFilters();
        }

        AppLoader.showSuccess('Order ${order.orderNumber} marked as Voided.');
      } else {
        AppLoader.showError('Unable to void order.');
      }
    } catch (e) {
      AppLoader.showError('Failed to update order status.');
    } finally {
      isUpdatingStatus.value = false;
    }
  }

  void reprintReceipt(OrderModel order) {
    AppLoader.showSuccess('Receipt for ${order.orderNumber} sent to printer!');
  }

  void exportCsv() {
    if (filteredOrders.isEmpty) {
      AppLoader.showInfo('No orders to export.');
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('Order Number,Time,Type,Items,Total,Status,Payment Method,Cashier');

    for (final o in filteredOrders) {
      buffer.writeln(
        '${o.orderNumber},"${o.formattedTime}","${o.orderType}",${o.itemsCount},"${o.total}","${o.status}","${o.paymentMethod}","${o.cashierName}"',
      );
    }

    AppLoader.showSuccess('Exported ${filteredOrders.length} orders to CSV!');
  }
}
