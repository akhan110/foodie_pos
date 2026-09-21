import 'package:flutter/material.dart';
import 'package:foodiepos/app/theme/app_theme.dart';
import 'package:foodiepos/app/theme/theme_controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  Get.put(ThemeController(), permanent: true);
  runApp(const BiteFlowApp());
}

class BiteFlowApp extends StatelessWidget {
  const BiteFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BiteFlow APP',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode.value,
      initialRoute: AppRoutes.login,
      getPages: AppPages.pages,
    );
  }
}
// class BiteFlowApp extends StatelessWidget {
//   const BiteFlowApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final ThemeController themeController = Get.find<ThemeController>();

//     return Obx(
//       () => GetMaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'BiteFlow POS',
//         theme: AppTheme.lightTheme,
//         darkTheme: AppTheme.darkTheme,
//         themeMode: themeController.themeMode.value,
//         initialRoute: AppRoutes.login,
//         getPages: AppPages.pages,
//       ),
//     );
//   }
// }
