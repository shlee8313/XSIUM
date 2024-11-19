// lib\modules\widgets\settings\common_app_bar.dart
import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../core/controllers/theme_controller.dart';
import 'common_settings_sheet.dart'; // CommonSettingsSheet import 추가

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? additionalActions;

  const CommonAppBar({
    super.key,
    required this.title,
    this.additionalActions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: Text(title),
      backgroundColor: theme.colorScheme.surface,
      actions: [
        if (additionalActions != null) ...additionalActions!,
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: const Icon(Icons.settings),
            color: theme.colorScheme.onSurface,
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const CommonSettingsSheet(),
                  opaque: false,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
