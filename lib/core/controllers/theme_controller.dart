// lib\core\session\controllers\theme_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static const String _themeKey = 'theme_mode';
  late SharedPreferences _prefs;
  var isDarkMode = false.obs;
  // 애니메이션을 위한 임시 상태
  var isAnimatingToDark = false.obs;
// themeMode getter 추가
  ThemeMode get themeMode =>
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      isDarkMode.value = _prefs.getBool(_themeKey) ?? false;
      isAnimatingToDark.value = isDarkMode.value;
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }

  void handleThemeChange(bool isDark) async {
    isDarkMode.value = isDark;
    await _prefs.setBool(_themeKey, isDark);
  }

  Future<void> toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    await _prefs.setBool(_themeKey, isDarkMode.value);
    _updateTheme();
  }

  void _updateTheme() {
    Get.changeThemeMode(
        themeMode); // isDarkMode.value ? ThemeMode.dark : ThemeMode.light 대신 getter 사용
  }
}
