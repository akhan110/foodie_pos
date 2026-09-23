import 'package:flutter_test/flutter_test.dart';
import 'package:foodiepos/models/base_response_model.dart';
import 'package:foodiepos/modules/kds/controllers/kds_controller.dart';
import 'package:foodiepos/modules/orders/models/order_model.dart';
import 'package:foodiepos/modules/orders/repository/orders_repository.dart';
import 'package:get/get.dart';

class MockOrdersRepository implements IOrdersRepository {
  List<OrderModel> orders = [];
  String? lastUpdatedStatus;
  String? lastUpdatedOrderId;

  @override
  Future<BaseResponseModel<List<OrderModel>>> getOrders({
    String? status,
    String? type,
    String? search,
  }) async {
    return BaseResponseModel<List<OrderModel>>(
      success: true,
      message: 'Orders retrieved',
      statusCode: 200,
      data: orders,
    );
  }

  @override
  Future<BaseResponseModel<OrderModel>> getOrderDetails(String orderId) async {
    final found = orders.firstWhere((o) => o.id == orderId);
    return BaseResponseModel<OrderModel>(
      success: true,
      message: 'Order retrieved',
      statusCode: 200,
      data: found,
    );
  }

  @override
  Future<BaseResponseModel<OrderModel>> createOrder(Map<String, dynamic> data) async {
    final newOrder = OrderModel.fromJson(data);
    orders.add(newOrder);
    return BaseResponseModel<OrderModel>(
      success: true,
      message: 'Order created',
      statusCode: 201,
      data: newOrder,
    );
  }

  @override
  Future<BaseResponseModel<OrderModel>> updateOrderStatus(String orderId, String status) async {
    lastUpdatedOrderId = orderId;
    lastUpdatedStatus = status;
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      orders[index] = orders[index].copyWith(status: status);
      return BaseResponseModel<OrderModel>(
        success: true,
        message: 'Status updated',
        statusCode: 200,
        data: orders[index],
      );
    }
    throw Exception('Order not found');
  }

  @override
  Future<BaseResponseModel<bool>> deleteOrder(String orderId) async {
    orders.removeWhere((o) => o.id == orderId);
    return BaseResponseModel<bool>(
      success: true,
      message: 'Order deleted',
      statusCode: 200,
      data: true,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockOrdersRepository mockRepo;
  late KdsController controller;

  final sampleOrders = [
    OrderModel(
      id: 'ord-1',
      orderNumber: '#1052',
      orderType: 'Dine In',
      status: 'New',
      tableNumber: 'Table 4',
      subtotal: 1000,
      total: 1000,
      amountReceived: 1000,
      createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
      items: [
        OrderItemModel(
          id: 'item-1',
          orderId: 'ord-1',
          productId: 'prod-1',
          productName: 'Smash Burger',
          quantity: 2,
          unitPrice: 500,
          totalPrice: 1000,
        ),
      ],
    ),
    OrderModel(
      id: 'ord-2',
      orderNumber: '#1050',
      orderType: 'Delivery',
      status: 'Preparing',
      subtotal: 1500,
      total: 1500,
      amountReceived: 1500,
      createdAt: DateTime.now().subtract(const Duration(minutes: 6)),
      items: [
        OrderItemModel(
          id: 'item-2',
          orderId: 'ord-2',
          productId: 'prod-2',
          productName: 'Pepperoni Pizza',
          quantity: 1,
          unitPrice: 1500,
          totalPrice: 1500,
        ),
      ],
    ),
    OrderModel(
      id: 'ord-3',
      orderNumber: '#1048',
      orderType: 'Dine In',
      status: 'Ready',
      tableNumber: 'Table 2',
      subtotal: 800,
      total: 800,
      amountReceived: 800,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      items: [
        OrderItemModel(
          id: 'item-3',
          orderId: 'ord-3',
          productId: 'prod-3',
          productName: 'Fries',
          quantity: 2,
          unitPrice: 400,
          totalPrice: 800,
        ),
      ],
    ),
    OrderModel(
      id: 'ord-4',
      orderNumber: '#1045',
      orderType: 'Takeaway',
      status: 'Completed', // Should be excluded from active kitchen board
      subtotal: 600,
      total: 600,
      amountReceived: 600,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      items: [],
    ),
  ];

  setUp(() {
    Get.testMode = true;
    mockRepo = MockOrdersRepository();
    mockRepo.orders = List.from(sampleOrders);
    controller = KdsController(ordersRepository: mockRepo);
  });

  tearDown(() {
    controller.onClose();
    Get.reset();
  });

  group('KdsController Tests', () {
    test('1. Loads active orders and excludes Completed orders', () async {
      await controller.fetchOrders();
      expect(controller.orders.length, 3);
      expect(controller.newOrders.length, 1);
      expect(controller.newOrders.first.orderNumber, '#1052');
      expect(controller.preparingOrders.length, 1);
      expect(controller.preparingOrders.first.orderNumber, '#1050');
      expect(controller.readyOrders.length, 1);
      expect(controller.readyOrders.first.orderNumber, '#1048');
    });

    test('2. Computes filter counts accurately', () async {
      await controller.fetchOrders();
      expect(controller.allCount, 3);
      expect(controller.dineInCount, 2);
      expect(controller.deliveryCount, 1);
      expect(controller.takeawayCount, 0);
      expect(controller.driveThruCount, 0);
    });

    test('3. Filters orders by type correctly', () async {
      await controller.fetchOrders();

      controller.setTypeFilter('Delivery');
      expect(controller.newOrders.length, 0);
      expect(controller.preparingOrders.length, 1);
      expect(controller.readyOrders.length, 0);

      controller.setTypeFilter('Dine In');
      expect(controller.newOrders.length, 1);
      expect(controller.preparingOrders.length, 0);
      expect(controller.readyOrders.length, 1);

      controller.setTypeFilter('All');
      expect(controller.newOrders.length, 1);
      expect(controller.preparingOrders.length, 1);
      expect(controller.readyOrders.length, 1);
    });

    test('4. Transitions order from New to Preparing when Start Cooking clicked', () async {
      await controller.fetchOrders();
      final newTicket = controller.newOrders.first;

      await controller.startCooking(newTicket);
      expect(mockRepo.lastUpdatedOrderId, 'ord-1');
      expect(mockRepo.lastUpdatedStatus, 'Preparing');

      expect(controller.newOrders.length, 0);
      expect(controller.preparingOrders.length, 2);
    });

    test('5. Transitions order from Preparing to Ready', () async {
      await controller.fetchOrders();
      final preparingTicket = controller.preparingOrders.first;

      await controller.markReady(preparingTicket);
      expect(mockRepo.lastUpdatedOrderId, 'ord-2');
      expect(mockRepo.lastUpdatedStatus, 'Ready');

      expect(controller.preparingOrders.length, 0);
      expect(controller.readyOrders.length, 2);
    });

    test('6. Marks order as Served / Completed and archives from KDS board', () async {
      await controller.fetchOrders();
      final readyTicket = controller.readyOrders.first;

      await controller.markServed(readyTicket);
      expect(mockRepo.lastUpdatedOrderId, 'ord-3');
      expect(mockRepo.lastUpdatedStatus, 'Completed');

      expect(controller.readyOrders.length, 0);
      expect(controller.orders.length, 2);
    });

    test('7. Toggles sound mute setting', () {
      expect(controller.isSoundMuted.value, false);
      controller.toggleSound();
      expect(controller.isSoundMuted.value, true);
      controller.toggleSound();
      expect(controller.isSoundMuted.value, false);
    });
  });
}
