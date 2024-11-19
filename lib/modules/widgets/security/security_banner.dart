// lib/presentation/screens/home/components/security_banner.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/theme_controller.dart';

class SecurityBanner extends StatelessWidget {
  const SecurityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          color: themeController.isDarkMode.value
              ? Colors.blue.withOpacity(0.2)
              : Colors.blue.withOpacity(0.1),
          child: Row(
            children: [
              Icon(
                Icons.security,
                size: 16,
                color: themeController.isDarkMode.value
                    ? Colors.white
                    : Colors.black,
              ),
              const SizedBox(width: 8),
              Text(
                'End-to-end encrypted',
                style: TextStyle(
                  color: themeController.isDarkMode.value
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ],
          ),
        ));
  }
}
