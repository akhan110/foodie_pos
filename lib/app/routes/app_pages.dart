import 'package:foodiepos/modules/login/bindings/login_bindings.dart';
import 'package:foodiepos/modules/login/views/login_view.dart';
import 'package:foodiepos/modules/pos/bindings/pos_binding.dart';
import 'package:foodiepos/modules/pos/views/pos_view.dart';
import 'package:foodiepos/modules/signup/bindings/signup_binding.dart';
import 'package:foodiepos/modules/signup/views/signup_view.dart';
import 'package:get/get.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupView(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: AppRoutes.pos,
      page: () => const PosView(),
      binding: PosBinding(),
    ),
  ];
}
