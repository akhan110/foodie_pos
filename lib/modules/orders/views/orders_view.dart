import 'package:flutter/material.dart';
import 'package:foodiepos/modules/orders/controllers/orders_controller.dart';
import 'package:foodiepos/modules/orders/widgets/order_details_widget.dart';
import 'package:foodiepos/modules/orders/widgets/orders_table_widget.dart';
import 'package:get/get.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrdersController());

    return Obx(() {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: controller.isViewingDetails.value
            ? const OrderDetailsWidget(key: ValueKey('order_details'))
            : const OrdersTableWidget(key: ValueKey('orders_table')),
      );
    });
  }
}
