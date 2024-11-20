import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  static LanguageController get to => Get.find();

  static const String _langKey = 'selected_language';
  late SharedPreferences _prefs;
  var currentLanguage = 'ko_KR'.obs;
  var isInitialized = false.obs;

  final List<Map<String, String>> languages = [
    {'code': 'ko_KR', 'name': '한국어'},
    {'code': 'en_US', 'name': 'English'},
    {'code': 'ja_JP', 'name': '日本語'},
    {'code': 'es_ES', 'name': 'Español'},
  ];

  @override
  void onInit() {
    super.onInit();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final savedLang = _prefs.getString(_langKey);

      if (savedLang != null) {
        currentLanguage.value = savedLang;
        updateLocale(savedLang);
      } else {
        final deviceLocale = Get.deviceLocale?.languageCode ?? 'en';
        String defaultLang;

        switch (deviceLocale) {
          case 'ko':
            defaultLang = 'ko_KR';
            break;
          case 'ja':
            defaultLang = 'ja_JP';
            break;
          case 'es':
            defaultLang = 'es_ES';
            break;
          default:
            defaultLang = 'en_US';
        }

        currentLanguage.value = defaultLang;
        await _prefs.setString(_langKey, defaultLang);
        updateLocale(defaultLang);
      }

      isInitialized.value = true;
    } catch (e) {
      debugPrint('Error loading language: $e');
      currentLanguage.value = 'en_US';
      updateLocale('en_US');
      isInitialized.value = true;
    }
  }

  void updateLocale(String langCode) {
    try {
      final locale = Locale(langCode.split('_')[0], langCode.split('_')[1]);
      Get.updateLocale(locale);
    } catch (e) {
      debugPrint('Error updating locale: $e');
    }
  }

  Future<void> changeLanguage(String langCode) async {
    try {
      currentLanguage.value = langCode;
      await _prefs.setString(_langKey, langCode);
      updateLocale(langCode);
    } catch (e) {
      debugPrint('Error changing language: $e');
    }
  }

  String getLanguageName(String langCode) {
    final lang = languages.firstWhere(
      (lang) => lang['code'] == langCode,
      orElse: () => {'code': langCode, 'name': langCode},
    );
    return lang['name'] ?? langCode;
  }
}
