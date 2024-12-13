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
              ? const Color(0x332196F3) //blueOpacity20 = Color(0x332196F3);
              : const Color(
                  0x1A2196F3), //Color blueOpacity10 = Color(0x1A2196F3);
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
