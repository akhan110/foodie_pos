// import 'package:flutter/material.dart';
// import 'package:foodiepos/app/widgets/custom_text_widget.dart';
// import 'package:foodiepos/modules/shell/controller/main_shell_controller.dart';
// import 'package:get/get.dart';

// import '../controllers/pos_controller.dart';
// import '../../shell/views/main_shell_view.dart';

// class PosView extends GetView<PosController> {
//   const PosView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<MainShellController>();
//     final ColorScheme colorScheme = Theme.of(context).colorScheme;
//     return MainShellView(
//       child: Row(
//         children: [
//           // Main product section
//           Expanded(
//             flex: 7,
//             child: Container(
//               color: colorScheme.surface,
//               child: Center(
//                 child: Column(
//                   children: [
//                     CustomTextWidget(
//                       'Products Area',
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     CustomTextWidget(
//                       controller.selectedIndex.toString(),
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // Current order / cart section
//           Expanded(
//             flex: 3,
//             child: Container(
//               color: colorScheme.surfaceContainerHighest,
//               child: const Center(
//                 child: CustomTextWidget(
//                   'Cart Area',
//                   style: TextStyle(fontSize: 18),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:foodiepos/modules/shell/views/new_order_view.dart';
import 'package:get/get.dart';

import '../controllers/pos_controller.dart';
import '../../shell/views/main_shell_view.dart';

class PosView extends GetView<PosController> {
  const PosView({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainShellView(child: NewOrderView());
  }
}
