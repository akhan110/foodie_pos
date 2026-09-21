import 'package:flutter/material.dart';
import 'package:foodiepos/app/widgets/app_bar_widget.dart';
import 'package:foodiepos/app/widgets/custom_text_widget.dart';
import 'package:foodiepos/app/widgets/unsupported_screen_view.dart';
import 'package:foodiepos/modules/pos/widgets/side_navigation.dart';
import 'package:foodiepos/modules/shell/controller/main_shell_controller.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

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
    return Scaffold(
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
                        return const Center(
                          child: CustomTextWidget('Orders Screen'),
                        );
                      }

                      if (controller.selectedIndex == 3) {
                        return const Center(
                          child: CustomTextWidget('Menu Screen'),
                        );
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
    );
  }
}
