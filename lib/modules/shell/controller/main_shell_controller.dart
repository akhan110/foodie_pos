import 'package:flutter/material.dart';
import 'package:foodiepos/app/constants/storage_keys.dart';
import 'package:foodiepos/app/routes/app_routes.dart';
import 'package:foodiepos/app/utils/app_loader.dart';
import 'package:foodiepos/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:foodiepos/modules/login/repository/login_repository.dart';
import 'package:foodiepos/modules/shifts/controllers/shift_controller.dart';
import 'package:foodiepos/modules/shifts/widgets/close_shift_dialog.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class MainShellController extends GetxController {
  final ILoginRepository _loginRepository;

  MainShellController({ILoginRepository? loginRepository})
      : _loginRepository = loginRepository ?? LoginRepository();

  int selectedIndex = 1;

  void updateIndex() {
    update();
  }

  void changePage(int index) {
    selectedIndex = index;
    update(['shell']);
    updateIndex();
  }

  void confirmLogout(BuildContext context) {
    if (!Get.isRegistered<ShiftController>()) {
      Get.put(ShiftController());
    }
    final shiftController = Get.find<ShiftController>();

    if (shiftController.currentShift.value != null) {
      CloseShiftDialog.show(
        context,
        shiftController,
        logoutOnClose: true,
      );
    } else {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Confirm Logout', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          content: const Text('Are you sure you want to log out of your session?', style: TextStyle(fontSize: 13)),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF04438),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  Future<void> logout() async {
    try {
      AppLoader.show(status: 'Logging out...');
      await _loginRepository.logout();
    } catch (_) {
      // Proceed with local logout regardless of network state
    } finally {
      final storage = GetStorage();
      await storage.remove(StorageKeys.token);
      await storage.remove(StorageKeys.tokenType);
      await storage.remove(StorageKeys.cashierId);
      await storage.remove(StorageKeys.cashierName);
      await storage.remove(StorageKeys.cashierRole);
      await storage.remove(StorageKeys.cashierStore);

      if (Get.isDialogOpen == true) {
        Get.back();
      }

      if (Get.isRegistered<ShiftController>()) {
        Get.find<ShiftController>().currentShift.value = null;
        Get.delete<ShiftController>(force: true);
      }

      if (Get.isRegistered<DashboardController>()) {
        Get.delete<DashboardController>(force: true);
      }

      AppLoader.showSuccess('Logged out successfully');
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
