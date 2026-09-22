import 'package:foodiepos/modules/login/repository/login_repository.dart';
import 'package:foodiepos/modules/shell/controllers/connectivity_controller.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ILoginRepository>(() => LoginRepository());
    Get.lazyPut<LoginController>(
      () => LoginController(loginRepository: Get.find<ILoginRepository>()),
    );
    Get.lazyPut<ConnectivityController>(() => ConnectivityController());
  }
}
