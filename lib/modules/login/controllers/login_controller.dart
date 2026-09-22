import 'package:foodiepos/app/constants/storage_keys.dart';
import 'package:foodiepos/app/routes/app_routes.dart';
import 'package:foodiepos/app/utils/app_loader.dart';
import 'package:foodiepos/modules/login/repository/login_repository.dart';
import 'package:foodiepos/services/network/api_exception.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  final ILoginRepository _loginRepository;

  LoginController({ILoginRepository? loginRepository})
      : _loginRepository = loginRepository ?? LoginRepository();

  final RxString pin = ''.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isLoading = false.obs;

  void onNumberPressed(String number) {
    if (isLoading.value) return;

    if (pin.value.length < 4) {
      pin.value += number;
      errorMessage.value = '';

      if (pin.value.length == 4) {
        verifyPin();
      }
    }
  }

  void onDeletePressed() {
    if (isLoading.value) return;

    if (pin.value.isNotEmpty) {
      pin.value = pin.value.substring(0, pin.value.length - 1);
      errorMessage.value = '';
    }
  }

  void clearPin() {
    pin.value = '';
    errorMessage.value = '';
  }

  Future<void> verifyPin() async {
    if (isLoading.value) return;

    if (pin.value.length != 4) {
      errorMessage.value = 'Please enter a 4-digit PIN';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      AppLoader.show(status: 'Verifying PIN...');

      final response = await _loginRepository.pinLogin(pin.value);

      if (response.success && response.data != null) {
        final authData = response.data!;
        final storage = GetStorage();

        // Save auth session & cashier info
        await storage.write(StorageKeys.token, authData.accessToken);
        await storage.write(StorageKeys.tokenType, authData.tokenType);
        await storage.write(StorageKeys.cashierId, authData.user.id);
        await storage.write(StorageKeys.cashierName, authData.user.name);
        await storage.write(StorageKeys.cashierRole, authData.user.role);
        await storage.write(StorageKeys.cashierStore, authData.user.storeName);

        AppLoader.showSuccess(
          response.message.isNotEmpty
              ? response.message
              : 'Welcome back, ${authData.user.name}!',
        );

        // Reset pin state
        pin.value = '';
        errorMessage.value = '';

        // Navigate to POS
        Get.offNamed(AppRoutes.pos);
      } else {
        final msg = response.message.isNotEmpty
            ? response.message
            : 'Invalid PIN. Please try again.';
        AppLoader.showError(msg);
        errorMessage.value = msg;
        _delayedClearPin();
      }
    } on ApiException catch (e) {
      final msg = e.message.isNotEmpty
          ? e.message
          : 'Invalid PIN. Please try again.';
      AppLoader.showError(msg);
      errorMessage.value = msg;
      _delayedClearPin();
    } catch (e) {
      const msg = 'Unable to connect to server. Check your connection.';
      AppLoader.showError(msg);
      errorMessage.value = msg;
      _delayedClearPin();
    } finally {
      isLoading.value = false;
    }
  }

  void _delayedClearPin() {
    Future.delayed(const Duration(milliseconds: 700), () {
      pin.value = '';
    });
  }

  void login() {
    if (pin.value.isEmpty) {
      errorMessage.value = 'Please enter 4-digit PIN';
      return;
    }
    verifyPin();
  }
}
