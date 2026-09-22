import 'package:foodiepos/modules/login/repository/login_repository.dart';
import 'package:foodiepos/modules/signup/controllers/signup_controller.dart';
import 'package:get/get.dart';

class SignupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ILoginRepository>(() => LoginRepository());
    Get.lazyPut<SignupController>(
      () => SignupController(loginRepository: Get.find<ILoginRepository>()),
    );
  }
}
