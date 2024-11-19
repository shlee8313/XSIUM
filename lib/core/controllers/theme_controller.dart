// lib\core\session\controllers\theme_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static const String _themeKey = 'theme_mode';
  late SharedPreferences _prefs;
  var isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    isDarkMode.value = _prefs.getBool(_themeKey) ?? false;
    _updateTheme();
  }

  Future<void> toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    await _prefs.setBool(_themeKey, isDarkMode.value);
    _updateTheme();
  }

  void _updateTheme() {
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}
