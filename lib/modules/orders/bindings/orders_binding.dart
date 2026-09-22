import 'package:foodiepos/modules/orders/controllers/orders_controller.dart';
import 'package:foodiepos/modules/orders/repository/orders_repository.dart';
import 'package:get/get.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IOrdersRepository>(() => OrdersRepository());
    Get.lazyPut<OrdersController>(
      () => OrdersController(repository: Get.find<IOrdersRepository>()),
    );
  }
}
