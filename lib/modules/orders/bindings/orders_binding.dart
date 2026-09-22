import 'package:foodiepos/modules/orders/repository/orders_repository.dart';
import 'package:get/get.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IOrdersRepository>(() => OrdersRepository());
  }
}
