import 'package:flutter/material.dart';
import 'package:foodiepos/modules/payment/views/payment_view.dart';
import 'package:foodiepos/modules/pos/controllers/pos_controller.dart';
import 'package:foodiepos/modules/pos/widgets/new_order/left_view_products/product_section.dart';
import 'package:foodiepos/modules/pos/widgets/new_order/right_view_cart/cart_section.dart';
import 'package:get/get.dart';

class NewOrderView extends GetView<PosController> {
  const NewOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: controller.isPaymentView.value
            ? const PaymentView(key: ValueKey('payment_view'))
            : Row(
                key: const ValueKey('pos_cart_view'),
                children: [
                  const Expanded(child: ProductSection()),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: theme.dividerColor,
                  ),
                  const SizedBox(
                    width: 360,
                    child: CartSection(),
                  ),
                ],
              ),
      );
    });
  }
}

