// lib\modules\settings\language_setting.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/language_controller.dart';

class LanguageSettings extends StatelessWidget {
  final languageController = Get.find<LanguageController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('language'.tr),
      ),
      body: Obx(
        () => ListView.builder(
          itemCount: languageController.languages.length,
          itemBuilder: (context, index) {
            final lang = languageController.languages[index];
            final langCode = lang['code']!;

            return RadioListTile<String>(
              title: Text(lang['name']!),
              value: langCode,
              groupValue: languageController.currentLanguage.value,
              onChanged: (value) {
                if (value != null) {
                  languageController.changeLanguage(value);
                }
              },
            );
          },
        ),
      ),
    );
  }
}
