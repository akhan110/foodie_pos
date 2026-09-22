import 'package:foodiepos/modules/payment/repository/payment_repository.dart';
import 'package:get/get.dart';

class PaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IPaymentRepository>(() => PaymentRepository());
  }
}
