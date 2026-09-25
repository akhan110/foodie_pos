import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodiepos/app/constants/storage_keys.dart';
import 'package:foodiepos/app/routes/app_pages.dart';
import 'package:foodiepos/app/routes/app_routes.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/app/theme/app_theme.dart';
import 'package:foodiepos/app/theme/theme_controller.dart';
import 'package:foodiepos/services/network/network.dart';
import 'package:foodiepos/services/network/network_config.dart';
import 'package:foodiepos/services/receipt_settings_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Initialize Network singleton
  final storage = GetStorage();
  Network.instance.init(
    config: NetworkConfig(
      baseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://foodiepos-five.vercel.app',
      ),
      tokenProvider: () async {
        return storage.read<String>(StorageKeys.token);
      },
      onUnauthorized: () async {
        await storage.remove(StorageKeys.token);
        Get.offAllNamed(AppRoutes.login);
      },
    ),
  );
  // Configure EasyLoading global indicator style
  _configureEasyLoading();
  Get.put(ThemeController(), permanent: true);
  Get.put(ReceiptSettingsService(), permanent: true);
  runApp(const BiteFlowApp());
}

void _configureEasyLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.ring
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 42.0
    ..radius = 12.0
    ..progressColor = AppColors.primary
    ..backgroundColor = const Color(0xFF1E293B)
    ..indicatorColor = AppColors.primary
    ..textColor = Colors.white
    ..maskColor = Colors.black.withValues(alpha: 0.4)
    ..userInteractions = false
    ..dismissOnTap = false;
}

class BiteFlowApp extends StatelessWidget {
  const BiteFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'BiteFlow POS',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode.value,
        initialRoute: AppRoutes.login,
        getPages: AppPages.pages,
        builder: EasyLoading.init(),
      ),
    );
  }
}
