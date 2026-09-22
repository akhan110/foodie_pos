import 'package:flutter/material.dart';
import 'package:foodiepos/app/constants/storage_keys.dart';
import 'package:foodiepos/app/routes/app_routes.dart';
import 'package:foodiepos/app/utils/app_loader.dart';
import 'package:foodiepos/modules/login/repository/login_repository.dart';
import 'package:foodiepos/services/network/api_exception.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SignupController extends GetxController {
  final ILoginRepository _loginRepository;

  SignupController({ILoginRepository? loginRepository})
      : _loginRepository = loginRepository ?? LoginRepository();

  final fullNameController = TextEditingController();
  final storeNameController = TextEditingController();
  final pinController = TextEditingController();
  final confirmPinController = TextEditingController();

  final RxBool isPinVisible = false.obs;
  final RxBool isConfirmPinVisible = false.obs;
  final RxBool agreeToTerms = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onClose() {
    fullNameController.dispose();
    storeNameController.dispose();
    pinController.dispose();
    confirmPinController.dispose();
    super.onClose();
  }

  void togglePinVisibility() {
    isPinVisible.value = !isPinVisible.value;
  }

  void toggleConfirmPinVisibility() {
    isConfirmPinVisible.value = !isConfirmPinVisible.value;
  }

  void toggleAgreeToTerms(bool? value) {
    agreeToTerms.value = value ?? false;
    errorMessage.value = '';
  }

  Future<void> createAccount() async {
    final name = fullNameController.text.trim();
    final storeName = storeNameController.text.trim();
    final pin = pinController.text.trim();
    final confirmPin = confirmPinController.text.trim();

    errorMessage.value = '';

    if (name.isEmpty) {
      errorMessage.value = 'Please enter your full name';
      return;
    }
    if (storeName.isEmpty) {
      errorMessage.value = 'Please enter your restaurant/store name';
      return;
    }
    if (pin.isEmpty || pin.length != 4 || !RegExp(r'^[0-9]{4}$').hasMatch(pin)) {
      errorMessage.value = 'PIN must be exactly 4 digits';
      return;
    }
    if (pin != confirmPin) {
      errorMessage.value = 'PINs do not match';
      return;
    }
    if (!agreeToTerms.value) {
      errorMessage.value = 'Please agree to the Terms of Service & Privacy Policy';
      return;
    }

    try {
      isLoading.value = true;
      AppLoader.show(status: 'Creating account...');

      final response = await _loginRepository.signUp(
        name: name,
        pin: pin,
        role: 'manager',
        storeName: storeName,
      );

      if (response.success && response.data != null) {
        final authData = response.data!;
        final storage = GetStorage();

        await storage.write(StorageKeys.token, authData.accessToken);
        await storage.write(StorageKeys.tokenType, authData.tokenType);
        await storage.write(StorageKeys.cashierId, authData.user.id);
        await storage.write(StorageKeys.cashierName, authData.user.name);
        await storage.write(StorageKeys.cashierRole, authData.user.role);
        await storage.write(StorageKeys.cashierStore, authData.user.storeName);

        AppLoader.showSuccess(response.message.isNotEmpty
            ? response.message
            : 'Welcome to BiteFlow POS!');

        Get.offAllNamed(AppRoutes.pos);
      } else {
        final msg = response.message.isNotEmpty ? response.message : 'Registration failed';
        errorMessage.value = msg;
        AppLoader.showError(msg);
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      AppLoader.showError(e.message);
    } catch (e) {
      const msg = 'Unable to complete signup. Please try again.';
      errorMessage.value = msg;
      AppLoader.showError(msg);
    } finally {
      isLoading.value = false;
    }
  }
}
