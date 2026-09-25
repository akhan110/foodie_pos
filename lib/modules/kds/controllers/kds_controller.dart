import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodiepos/app/routes/app_routes.dart';
import 'package:foodiepos/app/services/sound_service.dart';
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

  // Track in-flight network status transitions to prevent duplicate rapid taps
  final RxSet<String> updatingOrderIds = <String>{}.obs;

  // Track newly arrived order IDs to shake the ticket card for 3 to 4 seconds
  final RxSet<String> shakingOrderIds = <String>{}.obs;

  // Pending status overrides (orderId -> desiredStatus) to shield against heartbeat race conditions
  final Map<String, String> _pendingStatusMap = {};

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
        final rawFetched = response.data!;

        // Build active kitchen orders list while applying pending optimistic shields
        final activeList = <OrderModel>[];

        for (final rawOrder in rawFetched) {
          final id = rawOrder.id;

          // If this order has a pending local transition, adhere to the client's desired state
          if (_pendingStatusMap.containsKey(id)) {
            final pending = _pendingStatusMap[id]!;
            if (pending == 'Completed' || pending == 'Voided') {
              // Order was marked completed/served; do not bring it back!
              continue;
            }
            // Retain user's target status (e.g. 'Preparing' or 'Ready')
            activeList.add(rawOrder.copyWith(status: pending));
            continue;
          }

          final s = rawOrder.status.toLowerCase().trim();
          if (s == 'new' || s == 'pending' || s == 'preparing' || s == 'ready') {
            activeList.add(rawOrder);
          }
        }

        // Sort by created time descending (most urgent / newest first)
        activeList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        // Check for brand new incoming tickets to play sound chime and trigger 3-4s card shake
        if (!_isFirstLoad) {
          final newOrdersList = activeList.where((o) {
            final s = o.status.toLowerCase().trim();
            final isNew = s == 'new' || s == 'pending';
            return isNew && !_knownOrderIds.contains(o.id);
          }).toList();

          if (newOrdersList.isNotEmpty) {
            if (!isSoundMuted.value) {
              _playOrderReceivedSound();
            }

            for (final order in newOrdersList) {
              shakingOrderIds.add(order.id);
              Timer(const Duration(milliseconds: 3500), () {
                shakingOrderIds.remove(order.id);
              });
            }
          }
        }

        _knownOrderIds.clear();
        for (final o in activeList) {
          _knownOrderIds.add(o.id);
        }
        _isFirstLoad = false;

        // Smart reconciliation: only assign if order count, IDs, or statuses actually changed
        if (_hasOrdersChanged(orders, activeList)) {
          orders.assignAll(activeList);
        }
      }
    } catch (_) {
      // Background silent retry
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  bool _hasOrdersChanged(List<OrderModel> current, List<OrderModel> incoming) {
    if (current.length != incoming.length) return true;
    for (int i = 0; i < current.length; i++) {
      if (current[i].id != incoming[i].id ||
          current[i].status.toLowerCase().trim() != incoming[i].status.toLowerCase().trim() ||
          current[i].items.length != incoming[i].items.length) {
        return true;
      }
    }
    return false;
  }

  void _playOrderReceivedSound() {
    if (!isSoundMuted.value) {
      SoundService.playOrderReceivedSound();
    }
  }

  void _playPreparedSound() {
    if (!isSoundMuted.value) {
      SoundService.playPreparedSound();
    }
  }

  void toggleSound() {
    isSoundMuted.toggle();
    if (!isSoundMuted.value) {
      _playOrderReceivedSound();
    }
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
    HapticFeedback.lightImpact();
    await _updateStatus(order, 'Preparing');
  }

  Future<void> markReady(OrderModel order) async {
    _playPreparedSound();
    await _updateStatus(order, 'Ready');
  }

  Future<void> markServed(OrderModel order) async {
    HapticFeedback.selectionClick();
    await _updateStatus(order, 'Completed');
  }

  Future<void> removeOrderFromKds(OrderModel order, {bool voidOrder = false}) async {
    if (updatingOrderIds.contains(order.id)) return;
    updatingOrderIds.add(order.id);

    final targetStatus = voidOrder ? 'Voided' : 'Completed';
    _pendingStatusMap[order.id] = targetStatus;

    // Optimistically remove from active list
    final index = orders.indexWhere((o) => o.id == order.id);
    if (index >= 0) {
      orders.removeAt(index);
      orders.refresh();
    }

    try {
      if (voidOrder) {
        await _ordersRepository.updateOrderStatus(order.id, 'Voided');
      } else {
        await _ordersRepository.updateOrderStatus(order.id, 'Completed');
      }
      AppLoader.showSuccess('Order ${order.orderNumber} removed from KDS');
    } catch (e) {
      debugPrint('Error removing order from KDS: $e');
    } finally {
      updatingOrderIds.remove(order.id);
    }
  }

  void promptRemoveOrder(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: isDark ? const Color(0xFF1E222B) : Colors.white,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'Remove Order',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to remove ${order.orderNumber} from the Kitchen Display?',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                removeOrderFromKds(order, voidOrder: false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text('Remove', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateStatus(OrderModel order, String newStatus) async {
    // 1. Guard against multi-tap race condition
    if (updatingOrderIds.contains(order.id)) return;
    updatingOrderIds.add(order.id);

    // 2. Lock the target status locally so background polling cannot overwrite it
    _pendingStatusMap[order.id] = newStatus;

    // 3. Optimistic local update
    final index = orders.indexWhere((o) => o.id == order.id);
    if (index >= 0) {
      if (newStatus == 'Completed' || newStatus == 'Voided') {
        orders.removeAt(index);
      } else {
        orders[index] = order.copyWith(status: newStatus);
      }
      orders.refresh();
    }

    // 4. Server API call
    try {
      await _ordersRepository.updateOrderStatus(order.id, newStatus);

      // Keep pending override active for 8 seconds to guard against any
      // read-replica latency or race with a concurrent background fetch
      Timer(const Duration(seconds: 8), () {
        if (_pendingStatusMap[order.id] == newStatus) {
          _pendingStatusMap.remove(order.id);
        }
      });
    } catch (_) {
      // Re-sync on failure
      _pendingStatusMap.remove(order.id);
      fetchOrders(showLoading: false);
    } finally {
      updatingOrderIds.remove(order.id);
    }
  }

  void exitKds() {
    Get.offAllNamed(AppRoutes.login);
  }
}
