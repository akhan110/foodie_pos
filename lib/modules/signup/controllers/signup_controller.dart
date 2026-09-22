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
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxString selectedCountryCode = '+92'.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxBool agreeToTerms = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onClose() {
    fullNameController.dispose();
    storeNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  void toggleAgreeToTerms(bool? value) {
    agreeToTerms.value = value ?? false;
    errorMessage.value = '';
  }

  Future<void> createAccount() async {
    final name = fullNameController.text.trim();
    final storeName = storeNameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    errorMessage.value = '';

    if (name.isEmpty) {
      errorMessage.value = 'Please enter your full name';
      return;
    }
    if (storeName.isEmpty) {
      errorMessage.value = 'Please enter your restaurant/store name';
      return;
    }
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      errorMessage.value = 'Please enter a valid email address';
      return;
    }
    if (password.isEmpty || password.length < 6) {
      errorMessage.value = 'Password must be at least 6 characters long';
      return;
    }
    if (password != confirmPassword) {
      errorMessage.value = 'Passwords do not match';
      return;
    }
    if (!agreeToTerms.value) {
      errorMessage.value = 'Please agree to the Terms of Service & Privacy Policy';
      return;
    }

    try {
      isLoading.value = true;
      AppLoader.show(status: 'Creating account...');

      final fullPhone = phone.isNotEmpty ? '${selectedCountryCode.value} $phone' : null;

      final response = await _loginRepository.signUp(
        name: name,
        pin: '1234', // Default quick POS PIN
        email: email,
        password: password,
        phone: fullPhone,
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

  void signUpWithGoogle() {
    AppLoader.showInfo('Google Sign-In is coming soon!');
  }
}
