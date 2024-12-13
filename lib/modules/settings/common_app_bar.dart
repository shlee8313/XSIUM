// lib\modules\widgets\settings\common_app_bar.dart
import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../core/controllers/theme_controller.dart';
import 'common_settings_sheet.dart'; // CommonSettingsSheet import 추가
import '../widgets/avartar/avatar.dart';
import '../../core/session/user_session.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? additionalActions;
  final _userSession = UserSession();

  CommonAppBar({
    super.key,
    required this.title,
    this.additionalActions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          title: Row(
            children: [
              const SizedBox(width: 14),
              Avatar(size: 32), // 크기 줄임
              const SizedBox(width: 8),
              Text(_userSession.displayName ?? 'User'),
            ],
          ),
          titleSpacing: 8,
          automaticallyImplyLeading: false,
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
                          CommonSettingsSheet(),
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
        ),
        Container(
          height: 0.5,
          color: theme.dividerColor.withAlpha(125),
        ),
      ],
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + 0.5); // 구분선 높이 포함
}
