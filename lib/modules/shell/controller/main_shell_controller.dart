import 'package:flutter/material.dart';
import 'package:foodiepos/app/constants/storage_keys.dart';
import 'package:foodiepos/app/routes/app_routes.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/app/utils/app_loader.dart';
import 'package:foodiepos/modules/login/repository/login_repository.dart';
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.error, size: 24),
            const SizedBox(width: 10),
            Text(
              'Lock Register & Logout',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to log out and return to the PIN screen?',
          style: TextStyle(
            fontSize: 14,
            color: colors.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              logout();
            },
            child: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
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

      AppLoader.showSuccess('Logged out successfully');
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
