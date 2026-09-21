import 'package:foodiepos/app/routes/app_routes.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final RxString pin = ''.obs;
  final RxString errorMessage = ''.obs;
  static const String validPin = '1234';

  void onNumberPressed(String number) {
    if (pin.value.length < 4) {
      pin.value += number;
      errorMessage.value = '';

      if (pin.value.length == 4) {
        verifyPin();
      }
    }
  }

  void onDeletePressed() {
    if (pin.value.isNotEmpty) {
      pin.value = pin.value.substring(0, pin.value.length - 1);
      errorMessage.value = '';
    }
  }

  void clearPin() {
    pin.value = '';
    errorMessage.value = '';
  }

  void verifyPin() {
    if (pin.value == validPin) {
      Get.offNamed(AppRoutes.pos);
    } else {
      errorMessage.value = 'Invalid PIN. Please enter 1234';
      Future.delayed(const Duration(milliseconds: 600), () {
        pin.value = '';
      });
    }
  }

  void login() {
    if (pin.value.isEmpty) {
      errorMessage.value = 'Please enter 4-digit PIN (1234)';
      return;
    }
    verifyPin();
  }
}

