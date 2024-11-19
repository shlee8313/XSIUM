import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  static const String _langKey = 'selected_language';
  late SharedPreferences _prefs;
  var currentLanguage = 'ko_KR'.obs;

  // 지원하는 언어 목록
  final List<Map<String, String>> languages = [
    {'code': 'ko_KR', 'name': '한국어'},
    {'code': 'en_US', 'name': 'English'},
    {'code': 'ja_JP', 'name': '日本語'},
    {'code': 'es_ES', 'name': 'Español'}, // 스페인어 추가
  ];

  @override
  void onInit() {
    super.onInit();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    _prefs = await SharedPreferences.getInstance();
    final savedLang = _prefs.getString(_langKey);
    if (savedLang != null) {
      currentLanguage.value = savedLang;
      updateLocale(savedLang);
    } else {
      // 기기 언어 감지
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
          defaultLang = 'es_ES'; // 스페인어 디바이스 감지 추가
          break;
        default:
          defaultLang = 'en_US';
      }

      currentLanguage.value = defaultLang;
      await _prefs.setString(_langKey, defaultLang);
      updateLocale(defaultLang);
    }
  }

  void updateLocale(String langCode) {
    final locale = Locale(langCode.split('_')[0], langCode.split('_')[1]);
    Get.updateLocale(locale);
  }

  Future<void> changeLanguage(String langCode) async {
    currentLanguage.value = langCode;
    await _prefs.setString(_langKey, langCode);
    updateLocale(langCode);
  }

  String getLanguageName(String langCode) {
    final lang = languages.firstWhere(
      (lang) => lang['code'] == langCode,
      orElse: () => {'code': langCode, 'name': langCode},
    );
    return lang['name'] ?? langCode;
  }
}
