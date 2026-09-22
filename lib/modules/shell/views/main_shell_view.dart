import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodiepos/app/widgets/app_bar_widget.dart';
import 'package:foodiepos/app/widgets/custom_text_widget.dart';
import 'package:foodiepos/app/widgets/unsupported_screen_view.dart';
import 'package:foodiepos/modules/menu/views/menu_management_view.dart';
import 'package:foodiepos/modules/orders/views/orders_view.dart';
import 'package:foodiepos/modules/pos/controllers/pos_controller.dart';
import 'package:foodiepos/modules/pos/widgets/new_order/dialogs/parked_orders_dialog.dart';
import 'package:foodiepos/modules/pos/widgets/side_navigation.dart';
import 'package:foodiepos/modules/shell/controller/main_shell_controller.dart';
import 'package:get/get.dart';

class MainShellView extends StatelessWidget {
  const MainShellView({
    super.key,
    required this.child,
    this.cashierName = 'Admin',
  });

  final Widget child;
  final String cashierName;

  static const double minimumPosWidth = 900;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < minimumPosWidth) {
          return const UnsupportedScreenView(minimumWidth: minimumPosWidth);
        }

        return _buildMainShell(context);
      },
    );
  }

  Widget _buildMainShell(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.f1): () {
          if (Get.isRegistered<MainShellController>()) {
            Get.find<MainShellController>().changePage(1);
          }
        },
        const SingleActivator(LogicalKeyboardKey.f2): () {
          if (Get.isRegistered<MainShellController>()) {
            Get.find<MainShellController>().changePage(2);
          }
        },
        const SingleActivator(LogicalKeyboardKey.f3): () {
          if (Get.isRegistered<MainShellController>()) {
            Get.find<MainShellController>().changePage(3);
          }
        },
        const SingleActivator(LogicalKeyboardKey.f4): () {
          if (Get.isRegistered<PosController>()) {
            final posCtrl = Get.find<PosController>();
            ParkedOrdersDialog.show(context, posCtrl);
          }
        },
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (Get.isRegistered<PosController>()) {
            final posCtrl = Get.find<PosController>();
            if (posCtrl.isPaymentView.value) {
              posCtrl.cancelPayment();
            }
          }
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Column(
            children: [
              SecondaryAppBar(),
              Expanded(
                child: Row(
                  children: [
                    const SideNavigation(),
                    Expanded(
                      child: GetBuilder<MainShellController>(
                        id: 'shell',
                        builder: (controller) {
                          if (controller.selectedIndex == 0) {
                            return const Center(
                              child: CustomTextWidget('Dashboard Screen'),
                            );
                          }

                          if (controller.selectedIndex == 1) {
                            return child;
                          }

                          if (controller.selectedIndex == 2) {
                            return const OrdersView();
                          }

                          if (controller.selectedIndex == 3) {
                            return const MenuManagementView();
                          }

                          if (controller.selectedIndex == 4) {
                            return const Center(
                              child: CustomTextWidget('Reports Screen'),
                            );
                          }

                          if (controller.selectedIndex == 5) {
                            return const Center(
                              child: CustomTextWidget('Users Screen'),
                            );
                          }

                          if (controller.selectedIndex == 6) {
                            return const Center(
                              child: CustomTextWidget('Settings Screen'),
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
