// lib\modules\settings\common_settings_sheet.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/theme_controller.dart';
import '../../core/controllers/language_controller.dart';
import '../coins/coin_balance_widget.dart';
import '../../core/session/user_session.dart';
import '../auth/views/login_screen.dart';
import '../widgets/avartar/avatar.dart';
import './language_setting.dart';

class CommonSettingsSheet extends StatelessWidget {
  const CommonSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeController = Get.find<ThemeController>();
    final languageController = Get.find<LanguageController>();

    return Scaffold(
      backgroundColor: Colors.black.withAlpha(128),
      body: Column(
        children: [
          Container(
            color: colorScheme.surface,
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back,
                              color: colorScheme.onSurface),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Avatar(),
                        Text(
                          "홍길동",
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(width: 40),
                        const CoinBalanceWidget(),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildSettingsTile(
                          context,
                          icon: Obx(() => Icon(
                                themeController.isDarkMode.value
                                    ? Icons.light_mode
                                    : Icons.dark_mode,
                                color: colorScheme.primary,
                              )),
                          title: 'theme'.tr,
                          onTap: themeController.toggleTheme,
                        ),
                        _buildSettingsTile(
                          context,
                          icon:
                              Icon(Icons.language, color: colorScheme.primary),
                          title: 'language'.tr,
                          subtitle: Obx(() => Text(
                                languageController.getLanguageName(
                                    languageController.currentLanguage.value),
                                style: theme.textTheme.bodyMedium,
                              )),
                          onTap: () {
                            // 보안 설정 화면으로 이동
                          },
                        ),
                        _buildSettingsTile(
                          context,
                          icon:
                              Icon(Icons.security, color: colorScheme.primary),
                          title: 'security'.tr,
                          onTap: () {
                            // 보안 설정 화면으로 이동
                          },
                        ),
                        _buildSettingsTile(
                          context,
                          icon: Icon(Icons.help_outline,
                              color: colorScheme.primary),
                          title: 'help'.tr,
                          onTap: () {
                            // 도움말 화면으로 이동
                          },
                        ),
                        _buildSettingsTile(
                          context,
                          icon: const Icon(Icons.logout, color: Colors.red),
                          title: 'logout'.tr,
                          titleStyle: TextStyle(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                          onTap: () => _handleLogout(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required Widget icon,
    required String title,
    Widget? subtitle,
    TextStyle? titleStyle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: icon,
      title: Text(
        title,
        style: titleStyle ?? theme.textTheme.titleMedium,
      ),
      subtitle: subtitle,
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: theme.colorScheme.onSurface.withOpacity(0.5),
      ),
      onTap: onTap,
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final userSession = UserSession();

    bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: colorScheme.surface,
          title: Text(
            'logout_title'.tr,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'logout_confirm_message'.tr,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('cancel'.tr),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text('logout'.tr),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await userSession.clear();

      Get.offAll(() => const LoginScreen());
    } catch (e) {
      Get.back();
      Get.snackbar(
        'error'.tr,
        'logout_error_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: colorScheme.errorContainer,
        colorText: colorScheme.onErrorContainer,
      );
    }
  }
}
