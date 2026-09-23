import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodiepos/app/widgets/app_bar_widget.dart';
import 'package:foodiepos/app/widgets/custom_text_widget.dart';
import 'package:foodiepos/app/widgets/unsupported_screen_view.dart';
import 'package:foodiepos/modules/dashboard/views/dashboard_view.dart';
import 'package:foodiepos/modules/deals/views/deals_view.dart';
import 'package:foodiepos/modules/menu/views/menu_management_view.dart';
import 'package:foodiepos/modules/orders/views/orders_view.dart';
import 'package:foodiepos/modules/pos/controllers/pos_controller.dart';
import 'package:foodiepos/modules/pos/widgets/new_order/dialogs/parked_orders_dialog.dart';
import 'package:foodiepos/modules/pos/widgets/side_navigation.dart';
import 'package:foodiepos/modules/settings/views/settings_view.dart';
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
          body: Row(
            children: [
              const SideNavigation(),
              Expanded(
                child: GetBuilder<MainShellController>(
                  id: 'shell',
                  builder: (controller) {
                    Widget currentScreen;
                    switch (controller.selectedIndex) {
                      case 0:
                        currentScreen = const DashboardView();
                        break;
                      case 1:
                        currentScreen = child;
                        break;
                      case 2:
                        currentScreen = const OrdersView();
                        break;
                      case 3:
                        currentScreen = const MenuManagementView();
                        break;
                      case 4:
                        currentScreen = const DealsView();
                        break;
                      case 5:
                        currentScreen = const Center(
                          child: CustomTextWidget('Reports Screen'),
                        );
                        break;
                      case 6:
                      case 7:
                        currentScreen = const SettingsView();
                        break;
                      default:
                        currentScreen = child;
                    }

                    // Only the active POS cashier screen (New Order) requires the SecondaryAppBar
                    if (controller.selectedIndex == 1) {
                      return Column(
                        children: [
                          const SecondaryAppBar(),
                          Expanded(child: currentScreen),
                        ],
                      );
                    }

                    return currentScreen;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
