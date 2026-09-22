import 'package:flutter_easyloading/flutter_easyloading.dart';

/// Safe wrapper around [FlutterEasyLoading] that guards against missing overlay in unit tests.
class AppLoader {
  AppLoader._();

  static bool get _hasOverlay {
    try {
      return EasyLoading.instance.overlayEntry != null;
    } catch (_) {
      return false;
    }
  }

  static void show({String? status}) {
    if (_hasOverlay) {
      EasyLoading.show(status: status);
    }
  }

  static void showSuccess(String status) {
    if (_hasOverlay) {
      EasyLoading.showSuccess(status);
    }
  }

  static void showError(String status) {
    if (_hasOverlay) {
      EasyLoading.showError(status);
    }
  }

  static void showInfo(String status) {
    if (_hasOverlay) {
      EasyLoading.showInfo(status);
    }
  }

  static void dismiss() {
    if (_hasOverlay) {
      EasyLoading.dismiss();
    }
  }
}
