// lib\modules\settings\language_setting.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/language_controller.dart';

class LanguageSettings extends StatelessWidget {
  LanguageSettings({super.key});

  final languageController = Get.find<LanguageController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'language'.tr,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (!languageController.isInitialized.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              itemCount: languageController.languages.length,
              itemBuilder: (context, index) {
                final lang = languageController.languages[index];
                final langCode = lang['code']!;
                final isSelected =
                    languageController.currentLanguage.value == langCode;

                return ListTile(
                  leading: Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  title: Text(
                    lang['name']!,
                    style: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      fontWeight: isSelected ? FontWeight.bold : null,
                    ),
                  ),
                  onTap: () async {
                    await languageController.changeLanguage(langCode);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
