import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodiepos/app/theme/theme_controller.dart';
import 'package:foodiepos/main.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    GetStorage.init();
    if (!Get.isRegistered<ThemeController>()) {
      Get.put(ThemeController(), permanent: true);
    }
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('BiteFlowApp mounts successfully on tablet/desktop POS viewport',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const BiteFlowApp());
    expect(find.byType(BiteFlowApp), findsOneWidget);
  });
}
