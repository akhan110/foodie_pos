import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  ThemeController() {
    themeMode = _readSavedTheme().obs;
  }

  static const String _themeKey = 'theme_mode';
  static const String _lightValue = 'light';
  static const String _darkValue = 'dark';

  final GetStorage _storage = GetStorage();
  late final Rx<ThemeMode> themeMode;

  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  void toggleTheme() {
    isDarkMode ? setLightTheme() : setDarkTheme();
  }

  void setLightTheme() {
    _applyTheme(ThemeMode.light, _lightValue);
  }

  void setDarkTheme() {
    _applyTheme(ThemeMode.dark, _darkValue);
  }

  void _applyTheme(ThemeMode mode, String storageValue) {
    themeMode.value = mode;
    Get.changeThemeMode(mode);
    _saveTheme(storageValue);
  }

  ThemeMode _readSavedTheme() {
    final String? savedTheme = _storage.read<String>(_themeKey);

    return savedTheme == _darkValue ? ThemeMode.dark : ThemeMode.light;
  }

  void _saveTheme(String value) {
    unawaited(_storage.write(_themeKey, value));
  }
}
