import 'package:foodiepos/modules/kds/controllers/kds_controller.dart';
import 'package:foodiepos/modules/orders/repository/orders_repository.dart';
import 'package:get/get.dart';

class KdsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IOrdersRepository>(() => OrdersRepository());
    Get.lazyPut<KdsController>(() => KdsController(ordersRepository: Get.find<IOrdersRepository>()));
  }
}
