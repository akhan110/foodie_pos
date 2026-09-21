import 'dart:async';

import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityController extends GetxController {
  final RxBool isOnline = false.obs;

  final InternetConnection _internetConnection = InternetConnection();
  StreamSubscription<InternetStatus>? _statusSubscription;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();
    _listenForConnectionChanges();
  }

  Future<void> _checkInitialConnection() async {
    try {
      isOnline.value = await _internetConnection.hasInternetAccess;
    } catch (_) {
      isOnline.value = false;
    }
  }

  void _listenForConnectionChanges() {
    _statusSubscription = _internetConnection.onStatusChange.listen(
      (status) {
        isOnline.value = status == InternetStatus.connected;
      },
      onError: (_) {
        isOnline.value = false;
      },
    );
  }

  @override
  void onClose() {
    _statusSubscription?.cancel();
    _statusSubscription = null;
    super.onClose();
  }
}
