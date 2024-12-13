// lib\core\session\controllers\theme_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static const String _themeKey = 'theme_mode';
  late SharedPreferences _prefs;
  var isDarkMode = false.obs;
  var _isFullyInitialized = false;

  // Lightweight initialization for login screen
  Future<void> initializeBasic() async {
    if (!_isFullyInitialized) {
      _prefs = await SharedPreferences.getInstance();
      isDarkMode.value = false; // Always start with light theme for login
    }
  }

  // Full initialization for main app
  Future<void> initializeFull() async {
    if (!_isFullyInitialized) {
      _prefs = await SharedPreferences.getInstance();
      isDarkMode.value = _prefs.getBool(_themeKey) ?? false;
      _isFullyInitialized = true;
    }
  }

  ThemeMode get themeMode =>
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleTheme() async {
    if (!_isFullyInitialized) return;
    isDarkMode.value = !isDarkMode.value;
    await _prefs.setBool(_themeKey, isDarkMode.value);
    Get.changeThemeMode(themeMode);
  }
}
