import 'package:flutter_test/flutter_test.dart';
import 'package:foodiepos/models/base_response_model.dart';
import 'package:foodiepos/modules/orders/controllers/orders_controller.dart';
import 'package:foodiepos/modules/orders/models/order_model.dart';
import 'package:foodiepos/modules/orders/repository/orders_repository.dart';
import 'package:get/get.dart';

class MockOrdersRepository implements IOrdersRepository {
  List<OrderModel> mockOrders = [
    OrderModel(
      id: 'ord-1048',
      orderNumber: '#1048',
      orderType: 'Dine in',
      status: 'Completed',
      tableNumber: 'Table 5',
      cashierName: 'Alex Khan',
      subtotal: 1860.0,
      total: 1860.0,
      amountReceived: 2000.0,
      changeAmount: 140.0,
      createdAt: DateTime.now(),
      itemsCount: 5,
      items: const [
        OrderItemModel(
          id: 'item-1',
          orderId: 'ord-1048',
          productName: 'Classic Smash Burger',
          quantity: 2,
          unitPrice: 620.0,
          totalPrice: 1240.0,
        ),
      ],
    ),
    OrderModel(
      id: 'ord-1047',
      orderNumber: '#1047',
      orderType: 'Takeaway',
      status: 'Completed',
      tableNumber: 'Counter',
      cashierName: 'Alex Khan',
      subtotal: 1050.0,
      total: 1050.0,
      amountReceived: 1050.0,
      changeAmount: 0.0,
      createdAt: DateTime.now(),
      itemsCount: 2,
    ),
    OrderModel(
      id: 'ord-1046',
      orderNumber: '#1046',
      orderType: 'Delivery',
      status: 'Preparing',
      tableNumber: 'Online Rider',
      cashierName: 'Alex Khan',
      subtotal: 1240.0,
      total: 1240.0,
      amountReceived: 1240.0,
      changeAmount: 0.0,
      createdAt: DateTime.now(),
      itemsCount: 3,
    ),
    OrderModel(
      id: 'ord-1045',
      orderNumber: '#1045',
      orderType: 'Dine in',
      status: 'Voided',
      tableNumber: 'Table 2',
      cashierName: 'Alex Khan',
      subtotal: 1430.0,
      total: 1430.0,
      amountReceived: 0.0,
      changeAmount: 0.0,
      createdAt: DateTime.now(),
      itemsCount: 3,
    ),
  ];

  @override
  Future<BaseResponseModel<List<OrderModel>>> getOrders({
    String? status,
    String? type,
    String? search,
  }) async {
    return BaseResponseModel<List<OrderModel>>(
      success: true,
      message: 'Success',
      data: mockOrders,
      statusCode: 200,
    );
  }

  @override
  Future<BaseResponseModel<OrderModel>> getOrderDetails(String orderId) async {
    final found = mockOrders.firstWhere((o) => o.id == orderId || o.orderNumber == orderId);
    return BaseResponseModel<OrderModel>(
      success: true,
      message: 'Success',
      data: found,
      statusCode: 200,
    );
  }

  @override
  Future<BaseResponseModel<OrderModel>> createOrder(Map<String, dynamic> data) async {
    final newOrder = OrderModel.fromJson(data);
    mockOrders.insert(0, newOrder);
    return BaseResponseModel<OrderModel>(
      success: true,
      message: 'Created',
      data: newOrder,
      statusCode: 201,
    );
  }

  @override
  Future<BaseResponseModel<OrderModel>> updateOrderStatus(String orderId, String status) async {
    final index = mockOrders.indexWhere((o) => o.id == orderId || o.orderNumber == orderId);
    if (index != -1) {
      final updated = mockOrders[index].copyWith(status: status);
      mockOrders[index] = updated;
      return BaseResponseModel<OrderModel>(
        success: true,
        message: 'Updated',
        data: updated,
        statusCode: 200,
      );
    }
    throw Exception('Order not found');
  }

  @override
  Future<BaseResponseModel<bool>> deleteOrder(String orderId) async {
    mockOrders.removeWhere((o) => o.id == orderId || o.orderNumber == orderId);
    return BaseResponseModel<bool>(
      success: true,
      message: 'Deleted',
      data: true,
      statusCode: 200,
    );
  }
}

void main() {
  group('OrdersController & Repository Tests', () {
    late MockOrdersRepository mockRepo;
    late OrdersController controller;

    setUp(() {
      Get.testMode = true;
      mockRepo = MockOrdersRepository();
      controller = OrdersController(repository: mockRepo);
    });

    test('1. loadOrders populates orders and applies local filters', () async {
      await controller.loadOrders();

      expect(controller.orders.length, 4);
      expect(controller.filteredOrders.length, 4);
      expect(controller.isViewingDetails.value, false);
    });

    test('2. Filter by Search Query filters order numbers and tables', () async {
      await controller.loadOrders();

      controller.searchController.text = '1048';
      controller.applyLocalFilters();
      expect(controller.filteredOrders.length, 1);
      expect(controller.filteredOrders.first.orderNumber, '#1048');

      controller.searchController.text = 'Table 2';
      controller.applyLocalFilters();
      expect(controller.filteredOrders.length, 1);
      expect(controller.filteredOrders.first.orderNumber, '#1045');

      controller.searchController.text = '';
      controller.applyLocalFilters();
      expect(controller.filteredOrders.length, 4);
    });

    test('3. Filter by Order Type and Status', () async {
      await controller.loadOrders();

      controller.onTypeFilterChanged('Dine in');
      expect(controller.filteredOrders.length, 2);

      controller.onStatusFilterChanged('Voided');
      expect(controller.filteredOrders.length, 1);
      expect(controller.filteredOrders.first.orderNumber, '#1045');

      controller.onTypeFilterChanged('All types');
      controller.onStatusFilterChanged('All statuses');
      expect(controller.filteredOrders.length, 4);
    });

    test('4. Selecting an order opens details and back returns to list', () async {
      await controller.loadOrders();

      final target = controller.orders.first;
      controller.selectOrder(target);

      expect(controller.isViewingDetails.value, true);
      expect(controller.selectedOrder.value?.orderNumber, '#1048');

      controller.backToOrdersList();
      expect(controller.isViewingDetails.value, false);
    });

    test('5. Voiding an order updates status and local list', () async {
      await controller.loadOrders();

      final target = controller.orders.first;
      controller.selectOrder(target);
      expect(controller.selectedOrder.value?.status, 'Completed');

      await controller.voidOrder(target);
      expect(controller.selectedOrder.value?.status, 'Voided');
      expect(controller.orders.first.status, 'Voided');
    });

    test('6. Export CSV generates export without crash', () async {
      await controller.loadOrders();
      expect(() => controller.exportCsv(), returnsNormally);
    });

    test('7. Deleting an order removes it from list and closes details view', () async {
      await controller.loadOrders();
      expect(controller.orders.length, 4);

      final target = controller.orders.first;
      controller.selectOrder(target);
      expect(controller.isViewingDetails.value, true);

      await controller.deleteOrder(target);
      expect(controller.orders.length, 3);
      expect(controller.orders.any((o) => o.id == target.id), false);
      expect(controller.selectedOrder.value, isNull);
      expect(controller.isViewingDetails.value, false);
    });
  });
}
