import 'package:foodiepos/modules/login/repository/login_repository.dart';
import 'package:foodiepos/modules/pos/repository/pos_repository.dart';
import 'package:foodiepos/modules/shell/controller/main_shell_controller.dart';
import 'package:foodiepos/modules/shell/controllers/connectivity_controller.dart';
import 'package:get/get.dart';

import '../controllers/pos_controller.dart';

class PosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ILoginRepository>(() => LoginRepository());
    Get.lazyPut<IPosRepository>(() => PosRepository());
    Get.lazyPut<MainShellController>(
      () => MainShellController(loginRepository: Get.find<ILoginRepository>()),
    );
    Get.lazyPut<ConnectivityController>(() => ConnectivityController());
    Get.lazyPut<PosController>(() => PosController());
  }
}
