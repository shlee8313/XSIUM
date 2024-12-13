// lib/presentation/widgets/invite_list_tile.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/controllers/theme_controller.dart';

class InviteListTile extends StatelessWidget {
  final Widget title;
  final Widget subtitle;
  final Widget trailing;

  const InviteListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() => Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: themeController.isDarkMode.value
                ? Colors.grey[900]
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: themeController.isDarkMode.value
                    ? Colors.black26
                    : const Color(
                        0x1A9E9E9E), // Color greyOpacity10 = Color(0x1A9E9E9E);
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.grey,
              ),
            ),
            title: title,
            subtitle: subtitle,
            trailing: trailing,
          ),
        ));
  }
}
