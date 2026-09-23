import 'dart:async';
import 'package:flutter/services.dart';
import 'package:foodiepos/app/routes/app_routes.dart';
import 'package:foodiepos/app/utils/app_loader.dart';
import 'package:foodiepos/modules/orders/models/order_model.dart';
import 'package:foodiepos/modules/orders/repository/orders_repository.dart';
import 'package:get/get.dart';

class KdsController extends GetxController {
  final IOrdersRepository _ordersRepository;

  KdsController({IOrdersRepository? ordersRepository})
      : _ordersRepository = ordersRepository ?? OrdersRepository();

  // All active orders fetched from server
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;

  // Selected order type filter: 'All', 'Dine In', 'Takeaway', 'Delivery', 'Drive Thru'
  final RxString selectedTypeFilter = 'All'.obs;

  // Sound alert enabled/disabled
  final RxBool isSoundMuted = false.obs;

  // Real-time clock string
  final RxString currentTime = ''.obs;

  // Track known order IDs to detect new incoming tickets for audio chime
  final Set<String> _knownOrderIds = {};
  bool _isFirstLoad = true;

  Timer? _syncTimer;
  Timer? _clockTimer;
  Timer? _elapsedTimer;

  @override
  void onInit() {
    super.onInit();
    _updateClock();
    _startTimers();
    fetchOrders(showLoading: true);
  }

  @override
  void onClose() {
    _syncTimer?.cancel();
    _clockTimer?.cancel();
    _elapsedTimer?.cancel();
    super.onClose();
  }

  void _updateClock() {
    final now = DateTime.now();
    currentTime.value = _formatCurrentClock(now);
  }

  String _formatCurrentClock(DateTime dt) {
    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final weekday = weekdays[dt.weekday - 1];
    final month = months[dt.month - 1];
    return '$hour12:$minute $ampm, $weekday, ${dt.day} $month ${dt.year}';
  }

  void _startTimers() {
    // 1. Clock timer - updates every second
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateClock());

    // 2. Fast background heartbeat sync - every 4 seconds
    _syncTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      fetchOrders(showLoading: false);
    });

    // 3. Elapsed ticket time ticker - every 30 seconds to refresh UI time labels
    _elapsedTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      orders.refresh();
    });
  }

  /// Fetch active kitchen orders (New, Preparing, Ready)
  Future<void> fetchOrders({bool showLoading = false}) async {
    try {
      if (showLoading && orders.isEmpty) {
        isLoading.value = true;
      }

      final response = await _ordersRepository.getOrders();
      if (response.success && response.data != null) {
        final allFetched = response.data!;

        // Filter only active kitchen orders (exclude Completed or Voided)
        final activeList = allFetched.where((o) {
          final s = o.status.toLowerCase().trim();
          return s == 'new' || s == 'pending' || s == 'preparing' || s == 'ready';
        }).toList();

        // Sort by created time descending (most urgent / newest first)
        activeList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        // Check for brand new incoming tickets to play sound chime
        if (!_isFirstLoad && !isSoundMuted.value) {
          final hasNew = activeList.any((o) {
            final s = o.status.toLowerCase().trim();
            final isNew = s == 'new' || s == 'pending';
            return isNew && !_knownOrderIds.contains(o.id);
          });

          if (hasNew) {
            _playChime();
          }
        }

        _knownOrderIds.clear();
        for (final o in activeList) {
          _knownOrderIds.add(o.id);
        }
        _isFirstLoad = false;

        orders.assignAll(activeList);
      }
    } catch (_) {
      // Background silent retry
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  void _playChime() {
    try {
      SystemSound.play(SystemSoundType.alert);
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  void toggleSound() {
    isSoundMuted.toggle();
    AppLoader.showInfo(isSoundMuted.value ? 'KDS Sound Muted' : 'KDS Sound Enabled');
  }

  void setTypeFilter(String type) {
    selectedTypeFilter.value = type;
  }

  // ===========================================================================
  // FILTERED ACTIVE LISTS FOR THE 3 KANBAN COLUMNS
  // ===========================================================================

  List<OrderModel> _filterByType(List<OrderModel> list) {
    final filter = selectedTypeFilter.value.toLowerCase().replaceAll(' ', '');
    if (filter == 'all') return list;

    return list.where((o) {
      final t = o.orderType.toLowerCase().replaceAll(' ', '');
      if (filter == 'dinein') return t.contains('dine');
      if (filter == 'takeaway') return t.contains('takeaway');
      if (filter == 'delivery') return t.contains('delivery');
      if (filter == 'drivethru') return t.contains('drive');
      return t == filter;
    }).toList();
  }

  List<OrderModel> get newOrders => _filterByType(
        orders.where((o) {
          final s = o.status.toLowerCase().trim();
          return s == 'new' || s == 'pending';
        }).toList(),
      );

  List<OrderModel> get preparingOrders => _filterByType(
        orders.where((o) => o.status.toLowerCase().trim() == 'preparing').toList(),
      );

  List<OrderModel> get readyOrders => _filterByType(
        orders.where((o) => o.status.toLowerCase().trim() == 'ready').toList(),
      );

  // ===========================================================================
  // COUNTS FOR TOP FILTER CHIPS
  // ===========================================================================

  int get allCount => orders.length;

  int get dineInCount =>
      orders.where((o) => o.orderType.toLowerCase().contains('dine')).length;

  int get takeawayCount =>
      orders.where((o) => o.orderType.toLowerCase().contains('takeaway')).length;

  int get deliveryCount =>
      orders.where((o) => o.orderType.toLowerCase().contains('delivery')).length;

  int get driveThruCount =>
      orders.where((o) => o.orderType.toLowerCase().contains('drive')).length;

  // ===========================================================================
  // KANBAN ACTIONS / STATUS TRANSITIONS
  // ===========================================================================

  Future<void> startCooking(OrderModel order) async {
    _playChime();
    await _updateStatus(order, 'Preparing');
  }

  Future<void> markReady(OrderModel order) async {
    _playChime();
    await _updateStatus(order, 'Ready');
  }

  Future<void> markServed(OrderModel order) async {
    _playChime();
    await _updateStatus(order, 'Completed');
  }

  Future<void> _updateStatus(OrderModel order, String newStatus) async {
    // 1. Optimistic local update
    final index = orders.indexWhere((o) => o.id == order.id);
    if (index >= 0) {
      if (newStatus == 'Completed') {
        orders.removeAt(index);
      } else {
        orders[index] = order.copyWith(status: newStatus);
      }
      orders.refresh();
    }

    // 2. Server API call
    try {
      await _ordersRepository.updateOrderStatus(order.id, newStatus);
    } catch (_) {
      // Re-sync on failure
      fetchOrders(showLoading: false);
    }
  }

  void exitKds() {
    Get.offAllNamed(AppRoutes.login);
  }
}
