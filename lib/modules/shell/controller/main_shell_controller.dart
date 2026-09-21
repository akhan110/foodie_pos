import 'package:get/get.dart';

class MainShellController extends GetxController {
  int selectedIndex = 1;

  void updateIndex() {
    update();
  }

  void changePage(int index) {
    selectedIndex = index;
    update(['shell']);
    updateIndex();
  }
}
