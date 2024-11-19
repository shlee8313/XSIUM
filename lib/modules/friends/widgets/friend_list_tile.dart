// lib/presentation/widgets/friend_list_tile.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import '../../../core/controllers/theme_controller.dart';
import '../../../core/controllers/theme_controller.dart';
import '../../../config/theme.dart';
// import '../../../core/controllers/theme_controller.dart';

class FriendListTile extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget subtitle;
  final Widget trailing;

  const FriendListTile({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
// final theme = Theme.of(context);
    final themeController = Get.find<ThemeController>();
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: themeController.isDarkMode.value
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: themeController.isDarkMode.value
                ? AppColors.surfaceDark
                : AppColors.surfaceLight,
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
        leading: leading,
        title: DefaultTextStyle(
          style: theme.textTheme.titleLarge!.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          child: title,
        ),
        subtitle: DefaultTextStyle(
          style: theme.textTheme.bodyMedium!.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          child: subtitle,
        ),
        trailing: trailing,
      ),
    );
  }
}
