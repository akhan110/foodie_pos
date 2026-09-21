import 'package:foodiepos/modules/shell/controller/main_shell_controller.dart';
import 'package:foodiepos/modules/shell/controllers/connectivity_controller.dart';
import 'package:get/get.dart';

import '../controllers/pos_controller.dart';

class PosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainShellController>(() => MainShellController());

    Get.lazyPut<ConnectivityController>(() => ConnectivityController());

    Get.lazyPut<PosController>(() => PosController());
  }
}
