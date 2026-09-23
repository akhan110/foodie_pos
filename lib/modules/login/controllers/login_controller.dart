import 'package:foodiepos/app/constants/storage_keys.dart';
import 'package:foodiepos/app/routes/app_routes.dart';
import 'package:foodiepos/app/utils/app_loader.dart';
import 'package:foodiepos/data/models/cashier_model.dart';
import 'package:foodiepos/modules/login/repository/login_repository.dart';
import 'package:foodiepos/modules/shifts/controllers/shift_controller.dart';
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

  // Active Cashiers for user selection
  final RxList<CashierModel> cashiers = <CashierModel>[].obs;
  final Rx<CashierModel?> selectedCashier = Rx<CashierModel?>(null);
  final RxBool isLoadingCashiers = false.obs;
  final RxBool isKdsMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCashiers();
  }

  Future<void> loadCashiers() async {
    try {
      isLoadingCashiers.value = true;
      final res = await _loginRepository.getCashiers();
      if (res.success && res.data != null && res.data!.isNotEmpty) {
        cashiers.assignAll(res.data!);
        final savedId = GetStorage().read(StorageKeys.cashierId);
        final match = cashiers.firstWhereOrNull((c) => c.id == savedId);
        selectedCashier.value = match ?? cashiers.first;
      } else {
        cashiers.assignAll([
          CashierModel(id: 'alex-khan', name: 'Akhan', role: 'Cashier', storeName: 'Store #01', isActive: true),
          CashierModel(id: 'sarah-smith', name: 'Sarah Smith', role: 'Manager', storeName: 'Store #01', isActive: true),
          CashierModel(id: 'akhan', name: 'Akhan', role: 'manager', storeName: 'Kucks', isActive: true),
        ]);
        selectedCashier.value = cashiers.first;
      }
    } catch (e) {
      cashiers.assignAll([
        CashierModel(id: 'alex-khan', name: 'Akhan', role: 'Cashier', storeName: 'Store #01', isActive: true),
        CashierModel(id: 'sarah-smith', name: 'Sarah Smith', role: 'Manager', storeName: 'Store #01', isActive: true),
        CashierModel(id: 'akhan', name: 'Akhan', role: 'manager', storeName: 'Kucks', isActive: true),
      ]);
      selectedCashier.value = cashiers.first;
    } finally {
      isLoadingCashiers.value = false;
    }
  }

  void selectCashier(CashierModel? cashier) {
    if (cashier != null) {
      selectedCashier.value = cashier;
      clearPin();
    }
  }

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

      final response = await _loginRepository.pinLogin(
        pin.value,
        cashierId: selectedCashier.value?.id,
      );

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

        // Navigate to KDS or POS counter
        if (isKdsMode.value) {
          await Get.offNamed(AppRoutes.kds);
        } else {
          await Get.offNamed(AppRoutes.pos);

          // Prompt Open Shift dialog if no shift is currently open
          Future.delayed(const Duration(milliseconds: 350), () {
            if (!Get.isRegistered<ShiftController>()) {
              Get.put(ShiftController());
            }
            Get.find<ShiftController>().checkAndPromptOpenShift();
          });
        }
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
